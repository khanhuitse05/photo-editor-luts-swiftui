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
import PixelEngine

class PECtl : ObservableObject{
    public enum Action {
        case setFilter((inout EditingStack.Edit.Filters) -> Void)
        case commit
        case revert
        case undo
    }
    
    static var shared = PECtl()
    init() {
        print("init PECtl")
        collections = []
    }
    
    
    var originUI:UIImage!
    var originCI:CIImage!
    
    var filters:[FilterModel] = [
        FilterModel("Brightness", edit: EditMenu.exposure),
        FilterModel("Contrast", edit: EditMenu.contrast),
        FilterModel("Saturation", edit: EditMenu.saturation),
        FilterModel("HSL",image: "hls", edit: EditMenu.hls),
        FilterModel("White Blance",image:"temperature", edit: EditMenu.white_balance),
        FilterModel("Tone",image: "tone", edit: EditMenu.tone),
        FilterModel("Fade", edit: EditMenu.fade),
        FilterModel("Vignette", edit: EditMenu.vignette),
        FilterModel("Sharpen", edit: EditMenu.sharpen),
        FilterModel("Unsharp", image: "clarity",edit: EditMenu.clarity),
        FilterModel("Gaussian Blur", image: "cil_blur",edit: EditMenu.gaussianBlur),
    ]
    
    @Published var image:UIImage?
    @Published var currentFilter:FilterModel = noneFilterModel
    @Published var editingLut:Bool = false
    @Published var loadingLut:Bool = false
    var index:EditMenu{
        get{
            return currentFilter.edit
        }
    }
    
    var edit: EditingStack!
    
    // call after pick image
    func setImage(image:UIImage) {
        /// resetUI
        loadingLut = true
        currentFilter = noneFilterModel
        currentCollection = ""
        currentCube = ""
        self.image = nil
        for collection in collections{
            collection.reset()
        }
        /// setImage
        self.cubeSourceCG = nil
        self.originUI = image
        collections = Data.shared.collections
        DispatchQueue.global(qos: .userInteractive).async {
            self.originCI = convertUItoCI(from: image)
            self.edit = EditingStack.init(
                source: StaticImageSource(source: self.originCI!),
                previewSize: CGSize(width: 512, height: 512 * self.originUI.size.width / self.originUI.size.height)
            )
            self.apply()
            self.initCube()
        }
    }
    
    var collections:[Collection]
    var cubeSourceCI:CIImage?
    var cubeSourceCG:CGImage?
    @Published var currentCollection:String = ""
    @Published var currentCube:String = ""
    var cubes: [PreviewFilterColorCube]{
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
    
    private func initCube(){
        self.cubeSourceCI = resizedImage(at: self.originCI, scale: 128 / self.originUI.size.height, aspectRatio: 1)
        self.cubeSourceCG = sharedContext.createCGImage(self.cubeSourceCI!, from: self.cubeSourceCI!.extent)!
        for collection in collections {
            collection.setImage(image: cubeSourceCI)
        }
        DispatchQueue.main.async {
            self.loadingLut = false
        }
    }
    
    @Published var countEdit:Int = 1
    func didReceive(action: PECtl.Action) {
        switch action {
        case .setFilter(let closure):
            edit.set(filters: closure)
        case .commit:
            if(edit != nil){
                edit.commit()
            }
        case .undo:
            if(edit.canUndo){
                edit.undo()
                let name = edit.currentEdit.filters.colorCube?.identifier ?? ""
                currentCube = name
            }
        case .revert:
            edit.revert()
        }
        apply()
    }
    
    private func apply() {
        DispatchQueue.main.async {
            guard let preview:CIImage = self.edit.previewImage else{
                return
            }
            if let cgimg = sharedContext.createCGImage(preview, from: preview.extent) {
                self.image = UIImage(cgImage: cgimg)
            }
            self.countEdit = self.edit.edits.count
            
        }
    }
    
    func exportOrigin() {
        let exportFile =  self.edit.makeRenderer().render(resolution: .full)
        ImageSaver().writeToPhotoAlbum(image: exportFile)
    }
}
