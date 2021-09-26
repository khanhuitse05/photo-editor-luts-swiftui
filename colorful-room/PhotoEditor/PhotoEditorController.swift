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

class PECtl : ObservableObject{
    
    public enum Action {
        case setFilter((inout EditingStack.Edit.Filters) -> Void)
        case applyFilter((inout EditingStack.Edit.Filters) -> Void)
        case commit
        case revert
        case undo
        case adjust(CropperState?)
    }
    
    static var shared = PECtl()
    
    private let queue = DispatchQueue(
        label: "com.jimmy.luts",
        qos: .default,
        attributes: []
    )
    
    init() {
        print("init PECtl")
        collections = []
    }
    
    // origin image: pick from gallery or camera
    var originUI:UIImage!
    // cache origin: conver from UI to CI
    var originCI:CIImage!
    
    var filters:[FilterModel] = [
        FilterModel("Brightness", edit: EditMenu.exposure),
        FilterModel("Contrast", edit: EditMenu.contrast),
        FilterModel("Saturation", edit: EditMenu.saturation),
        FilterModel("White Blance",image:"temperature", edit: EditMenu.white_balance),
        FilterModel("Tone",image: "tone", edit: EditMenu.tone),
        FilterModel("HSL",image: "hls", edit: EditMenu.hls),
        FilterModel("Fade", edit: EditMenu.fade),
    ]
    
    var cropperState:CropperState?
    
    var editState: EditingStack!
    
    var currentEditMenu:EditMenu{
        get{
            return currentFilter.edit
        }
    }

    
    // Image preview: will update after edited
    @Published var previewImage:UIImage?
    
    @Published var currentFilter:FilterModel = FilterModel.noneFilterModel
    @Published var editingLut:Bool = false
    @Published var loadingLut:Bool = false
    
    // Cube
    var collections:[Collection]
    var cubeSourceCI:CIImage?
    var cubeSourceCG:CGImage?
    @Published var currentCollection:String = ""
    @Published var currentCube:String = ""
    
    var currentCubes: [PreviewFilterColorCube]{
        get{
            if(currentCollection.isEmpty){
                return []
            }
            for collection in collections{
                if(collection.identifier == currentCollection){
                    return collection.cubePreviews
                }
            }
            return []
        }
    }
    
    // Export
    @Published var originExport:UIImage?
    
    
    func setImage(image:UIImage) {
        
        /// resetUI
        if(loadingLut == true){
            return
        }
        currentFilter = FilterModel.noneFilterModel
        currentCollection = ""
        currentCube = ""
        cropperState = nil
        /// setImage
        self.cubeSourceCG = nil
        self.originUI = image
        
        resetExport()
        loadingLut = true
        collections = Data.shared.collections
        queue.async {
            self.originCI = convertUItoCI(from: image)
            self.editState = EditingStack.init(
                source: StaticImageSource(source: self.originCI!),
                // todo: need more code to caculator adjust with scale image
                previewSize: CGSize(width: 512, height: 512 * self.originUI.size.width / self.originUI.size.height)
                // previewSize: CGSize(width: self.originUI.size.width, height: self.originUI.size.height)
            )
            self.apply()
            self.initCube()
        }
        
    }
    
    
    func initCube(){
        print("init Cube")
        self.cubeSourceCI = resizedImage(at: self.originCI, scale: 128 / self.originUI.size.height, aspectRatio: 1)
        self.cubeSourceCG = sharedContext.createCGImage(self.cubeSourceCI!, from: self.cubeSourceCI!.extent)!
        
        
        for collection in self.collections {
            collection.setImage(image: self.cubeSourceCI)
        }
        DispatchQueue.main.async {
            self.loadingLut = false
        }
        
    }
    
    
    func didReceive(action: PECtl.Action) {
        switch action {
        case .setFilter(let closure):
            setFilterDelay(filters: closure)
        case .commit:
            if(editState != nil){
                editState.commit()
            }
        case .applyFilter(let closure):
            self.editState.set(filters: closure)
            self.editState.commit()
            self.apply()
            
        case .undo:
            if(editState?.canUndo == true){
                self.editState.undo()
                let name = self.editState.currentEdit.filters.colorCube?.identifier ?? ""
                self.currentCube = name
                self.apply()
            }

        case .revert:
            self.editState.revert()
            self.apply()
            
        case .adjust(let state):
            self.cropperState = state
        }
    }
    
    var count:Int  = 0
    func setFilterDelay(filters: (inout EditingStack.Edit.Filters) -> Void) {
        self.count = self.count + 1
        let currentCount = self.count
        self.editState.set(filters: filters)
        queue.asyncAfter(deadline: .now() + 0.3, execute: {
            // escaping closure captures non-escaping parameter
            if (self.count == currentCount){
                self.count  = 0
                self.apply()
            }else if (currentCount % 20 == 0){
                self.apply()
            }
        })
    }
    
    func apply() {
        guard let preview:CIImage = self.editState.previewImage else{
            return
        }
        DispatchQueue.main.async {
            if let cgimg = sharedContext.createCGImage(preview, from: preview.extent) {
                self.previewImage = UIImage(cgImage: cgimg)
            }
        }
        
    }
    
}


// Export extension
extension PECtl{
    
    func prepareExport() {
        if(originExport == nil){
            didReceive(action: .commit)
            DispatchQueue.main.async {
                if(self.cropperState != nil){
                    let originRender = self.originUI.cropped(withCropperState: self.cropperState!)
                    let source = StaticImageSource(source: convertUItoCI(from: originRender!))
                    self.originExport =  self.editState.makeCustomRenderer(source: source)
                        .render(resolution: .full)
                }else{
                    self.originExport = self.editState.makeRenderer().render(resolution: .full)
                }
            }
        }
    }
    
    func resetExport() {
        originExport = nil
    }
    
    func exportOrigin() {
        if let origin = self.originExport{
            ImageSaver().writeToPhotoAlbum(image: origin)
        }
        return
    }
}
