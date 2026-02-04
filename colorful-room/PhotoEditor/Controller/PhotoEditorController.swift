//
//  PhotoEditorController.swift
//  colorful-room
//
//  Created by macOS on 7/8/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import PixelEnginePackage
import QCropper
import CoreData

class PECtl : ObservableObject{
    
    static var shared = PECtl()
    
    init() {
        print("init PECtl")
    }
    
    // origin image: pick from gallery or camera
    var originUI:UIImage!
    // cache origin: conver from UI to CI
    var originCI:CIImage!
    // crop controller
    var cropperCtrl:CropperController = CropperController()
    // luts controller
    @NestedObservableObject
    var lutsCtrl:LutsController = LutsController()
    // recipes controller
    @NestedObservableObject
    var recipesCtrl:RecipeController = RecipeController()
    
    
    var editState: EditingStack!
    
    var currentEditMenu:EditMenu{
        get{
            return currentFilter.edit
        }
    }
    
    // Image preview: will update after edited
    @Published
    var previewImage:UIImage?
    
    // Getter
    @Published
    var currentRecipe:RecipeObject?
    
    // 
    @Published
    var currentFilter:FilterModel = FilterModel.noneFilterModel
    
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
        currentFilter = FilterModel.noneFilterModel
        self.originUI = image
        
        self.originCI = convertUItoCI(from: image)
        
        self.editState = EditingStack.init(
            source: StaticImageSource(source: self.originCI!),
            // todo: need more code to caculator adjust with scale image
            previewSize: CGSize(width: 512, height: 512 * self.originUI.size.width / self.originUI.size.height)
            // previewSize: CGSize(width: self.originUI.size.width, height: self.originUI.size.height)
        )
       
        
        if let smallImage = resizedImage(at: originCI, scale: 128 / self.originUI.size.height, aspectRatio: 1){
            lutsCtrl.setImage(image: smallImage)
            recipesCtrl.setImage(image: smallImage)
        }
        
        cropperCtrl = CropperController()

        Task.detached(priority: .background) {
            await self.apply()
        }
    }
    
    
    
    
    
    func didReceive(action: PECtlAction) {
        switch action {
        case .setFilter(let closure):
            setFilterDelay(filters: closure)
        case .commit:
            editState?.commit()
            
        case .applyFilter(let closure):
            self.currentRecipe = nil
            self.editState.set(filters: closure)
            self.editState.commit()
            Task { @MainActor in
                self.apply()
            }
            
        case .undo:
            if(editState?.canUndo == true){
                self.editState.undo()
                let name = self.editState.currentEdit.filters.colorCube?.identifier ?? ""
                self.lutsCtrl.selectCube(name)
                Task { @MainActor in
                    self.apply()
                }
            }

        case .revert:
            self.editState.revert()
            Task { @MainActor in
                self.apply()
            }
        
        case .applyRecipe(let recipeObject):
            self.onApplyRecipe(recipeObject)
            
        }
    }
    
    
    var count:Int  = 0
    func setFilterDelay(filters: (inout EditingStack.Edit.Filters) -> Void) {
        currentRecipe = nil
        self.count = self.count + 1
        let currentCount = self.count
        self.editState.set(filters: filters)
        Task.detached(priority: .background) { [weak self] in
            guard let self = self else { return }
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            // escaping closure captures non-escaping parameter
            if (self.count == currentCount){
                self.count  = 0
                await self.apply()
            }else if (currentCount % 20 == 0){
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

