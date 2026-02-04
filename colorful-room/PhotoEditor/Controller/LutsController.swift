//
//  LutsController.swift
//  colorful-room
//
//  Created by Ping9 on 28/06/2022.
//
import Foundation
import SwiftUI
import PixelEnginePackage
import CoreData

@MainActor
@Observable
class LutsController {
    
    var loadingLut: Bool = false
    
    // Cube
    var collections: [Collection] = []
    var cubeSourceCG: CGImage?
    
    var currentCube: String = ""
    var editingLut: Bool = false
    
    var showLoading:Bool{
        get{
            return loadingLut || cubeSourceCG == nil
        }
    }
    
    func setImage(image: CIImage) {
        currentCube = ""
        /// setImage – prepare state on the main actor
        cubeSourceCG = nil
        loadingLut = true
        
        // Take a non-optional snapshot of the current collections to work on off the main actor.
        guard let collectionsSnapshot = Data.shared.collections else {
            loadingLut = false
            return
        }
        collections = collectionsSnapshot
        
        Task.detached(priority: .background) {
            print("init Cube")
            guard let newCubeSourceCG = sharedContext.createCGImage(image, from: image.extent) else {
                await MainActor.run {
                    self.loadingLut = false
                }
                return
            }
            
            for collection in collectionsSnapshot {
                collection.setImage(image: image)
            }
            
            await MainActor.run {
                self.cubeSourceCG = newCubeSourceCG
                self.loadingLut = false
            }
        }
    }
    
    
    ///
    func selectCube(_ value:String){
        currentCube = value
    }
    
    ///
    func onSetEditingMode(_ value:Bool){
        editingLut = value
    }
    
}
