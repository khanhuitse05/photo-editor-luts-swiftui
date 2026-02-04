//
//  LutsController.swift
//  colorful-room
//
//  Created by Ping9 on 28/06/2022.
//
import Foundation
import Combine
import SwiftUI
import PixelEnginePackage
import CoreData

class LutsController : ObservableObject{
    
    @Published var loadingLut:Bool = false
    
    // Cube
    var collections:[Collection] = []
    var cubeSourceCG:CGImage?
    
    @Published var currentCube:String = ""
    @Published var editingLut:Bool = false
    
    var showLoading:Bool{
        get{
            return loadingLut || cubeSourceCG == nil
        }
    }
    
    func setImage(image:CIImage){
        currentCube = ""
        /// setImage
        self.cubeSourceCG = nil
        loadingLut = true
        collections = Data.shared.collections
        
        Task.detached(priority: .background) { [weak self] in
            guard let self = self else { return }
            print("init Cube")
            self.cubeSourceCG = sharedContext.createCGImage(image, from: image.extent)!
            
            for e in self.collections {
                e.setImage(image: image)
            }
            await MainActor.run {
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
