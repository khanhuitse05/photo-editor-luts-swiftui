//
//  PhotoEditorController.swift
//  colorful-room
//
//  Created by macOS on 7/8/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import Foundation
import SwiftUI
import PixelEnginePackage
import QCropper
import CoreData

@MainActor
@Observable
class PECtl {
    
    static var shared = PECtl()
    
    init() {
    }
    
    // origin image: pick from gallery or camera
    var originUI: UIImage!
    // cache origin: conver from UI to CI
    var originCI: CIImage!
    // crop controller
    var cropperCtrl: CropperController = CropperController()
    // luts controller
    var lutsCtrl: LutsController = LutsController()
    // recipes controller
    var recipesCtrl: RecipeController = RecipeController()
    
    
    var editState: EditingStack!
    
    // Redo stack: stores filter snapshots that were undone
    var redoStack: [EditingStack.Edit.Filters] = []
    
    var canRedo: Bool {
        return !redoStack.isEmpty
    }
    
    var currentEditMenu: EditMenu {
        get {
            return currentFilter.edit
        }
    }
    
    // Image preview: will update after edited
    var previewImage: UIImage?
    
    // Original preview rendered through the same pipeline (for before/after comparison)
    var originalPreview: UIImage?
    
    // Getter
    var currentRecipe: RecipeObject?
    
    // 
    var currentFilter: FilterModel = FilterModel.noneFilterModel
    
    // Check to show save recipe button
    var hasRecipeToSave: Bool{
        get{
            return editState.canUndo && currentRecipe == nil
        }
    }
    
    func setImage(image:UIImage) {
        
        /// resetUI
        if(lutsCtrl.loadingLut == true){
            return
        }
        redoStack.removeAll()
        currentFilter = FilterModel.noneFilterModel
        self.originUI = image
        
        self.originCI = convertUItoCI(from: image)
        
        self.editState = EditingStack.init(
            source: StaticImageSource(source: self.originCI!),
            previewSize: CGSize(width: DesignTokens.previewSize, height: DesignTokens.previewSize * self.originUI.size.width / self.originUI.size.height)
            // previewSize: CGSize(width: self.originUI.size.width, height: self.originUI.size.height)
        )
       
        
        if let smallImage = resizedImage(at: originCI, scale: DesignTokens.thumbnailScale / self.originUI.size.height, aspectRatio: 1){
            lutsCtrl.setImage(image: smallImage)
            recipesCtrl.setImage(image: smallImage)
        }
        
        cropperCtrl = CropperController()
        originalPreview = nil

        Task.detached(priority: .background) {
            await self.apply()
            // Capture the first render (no edits) as the comparison baseline
            await MainActor.run {
                if self.originalPreview == nil {
                    self.originalPreview = self.previewImage
                }
            }
        }
    }
    
    
    
    
    
    func didReceive(action: PECtlAction) {
        switch action {
        case .setFilter(let closure):
            redoStack.removeAll() // New edit clears redo
            setFilterDelay(filters: closure)
        case .commit:
            editState?.commit()
            
        case .applyFilter(let closure):
            redoStack.removeAll() // New edit clears redo
            self.currentRecipe = nil
            self.editState.set(filters: closure)
            self.editState.commit()
            Task { @MainActor in
                self.apply()
            }
            
        case .undo:
            if(editState?.canUndo == true){
                // Save current filters to redo stack before undoing
                let currentFilters = self.editState.currentEdit.filters
                redoStack.append(currentFilters)
                self.editState.undo()
                let name = self.editState.currentEdit.filters.colorCube?.identifier ?? ""
                self.lutsCtrl.selectCube(name)
                Task { @MainActor in
                    self.apply()
                }
            }

        case .redo:
            if let filtersToRedo = redoStack.popLast() {
                self.editState.set(filters: { $0 = filtersToRedo })
                self.editState.commit()
                let name = filtersToRedo.colorCube?.identifier ?? ""
                self.lutsCtrl.selectCube(name)
                Task { @MainActor in
                    self.apply()
                }
            }

        case .revert:
            redoStack.removeAll()
            self.editState.revert()
            Task { @MainActor in
                self.apply()
            }
        
        case .applyRecipe(let recipeObject):
            redoStack.removeAll() // New edit clears redo
            self.onApplyRecipe(recipeObject)
            
        }
    }
    
    
    var count: Int = 0
    func setFilterDelay(filters: (inout EditingStack.Edit.Filters) -> Void) {
        currentRecipe = nil
        self.count = self.count + 1
        let currentCount = self.count
        self.editState.set(filters: filters)
        Task.detached(priority: .background) { [weak self] in
            guard let self = self else { return }
            try? await Task.sleep(nanoseconds: DesignTokens.filterDebounceNanoseconds)
            // Check if this is still the latest request by accessing count on MainActor
            let isLatestRequest = await MainActor.run {
                if self.count == currentCount {
                    self.count = 0
                    return true
                }
                return false
            }
            
            if isLatestRequest {
                await self.apply()
            } else if currentCount % 20 == 0 {
                await self.apply()
            }
        }
    }
    
    
    @MainActor
    func apply() {
        guard let preview:CIImage = self.editState.previewImage else{
            return
        }
        if let cgimg = sharedContext.createCGImage(preview, from: preview.extent) {
            self.previewImage = UIImage(cgImage: cgimg)
        }
    }
    
    /// Called after the user confirms or clears a crop/rotation in the cropper.
    /// Rebuilds the editing stack using the cropped source while preserving current filter edits.
    func onCropStateChanged() {
        guard let originUI = originUI else { return }
        
        // Determine the source: cropped or original
        let sourceUI: UIImage
        if let cropperState = cropperCtrl.state,
           let croppedImage = originUI.cropped(withCropperState: cropperState) {
            sourceUI = croppedImage
        } else {
            sourceUI = originUI
        }
        
        let sourceCI = convertUItoCI(from: sourceUI)
        
        // Save current filter state before rebuilding
        let savedFilters = editState?.currentEdit.filters
        
        // Rebuild editing stack with the (possibly cropped) source
        self.editState = EditingStack(
            source: StaticImageSource(source: sourceCI),
            previewSize: CGSize(
                width: DesignTokens.previewSize,
                height: DesignTokens.previewSize * sourceUI.size.width / sourceUI.size.height
            )
        )
        
        // Update LUT and recipe thumbnails with the new source
        if let smallImage = resizedImage(at: sourceCI, scale: DesignTokens.thumbnailScale / sourceUI.size.height, aspectRatio: 1) {
            lutsCtrl.setImage(image: smallImage)
            recipesCtrl.setImage(image: smallImage)
        }
        
        Task.detached(priority: .background) {
            // 1. Render without filters → capture as originalPreview
            await self.apply()
            await MainActor.run {
                self.originalPreview = self.previewImage
            }
            
            // 2. Re-apply saved filters and render again
            if let filters = savedFilters {
                await MainActor.run {
                    self.editState.set(filters: { $0 = filters })
                    self.editState.commit()
                }
                await self.apply()
            }
        }
    }
    
    ///
    func onApplyRecipe(_ data:RecipeObject) {
        
        let colorCube:FilterColorCube? = Data.shared.cubeBy(identifier: data.lutIdentifier ?? "")
        self.currentRecipe = data
        
        self.editState.set(filters: RecipeUtils.applyRecipe(data, colorCube: colorCube))
        self.editState.commit()
        Task { @MainActor in
            self.apply()
        }
    }
    
}

