//
//  Export.swift
//  colorful-room
//
//  Created by Ping9 on 16/01/2022.
//

import Foundation
import Combine
import SwiftUI
import PixelEnginePackage
import QCropper
import CoreData


class ExportController : ObservableObject{
    
    // Export
    @Published var originExport:UIImage?
    
    var originRatio: Double {
        get{
            PECtl.shared.originUI.size.width/PECtl.shared.originUI.size.height;
        }
    }
    
    var controller: PECtl {
        get {
            PECtl.shared
        }
    }
    
    func prepareExport() {
        if(originExport == nil){
            controller.didReceive(action: .commit)
            DispatchQueue.main.async {
                if let cropperState = self.controller.cropperCtrl.state{
                    let originRender = self.controller.originUI.cropped(withCropperState: cropperState)
                    let source = StaticImageSource(source: convertUItoCI(from: originRender!))
                    self.originExport =  self.controller.editState.makeCustomRenderer(source: source)
                        .render(resolution: .full)
                }else{
                    self.originExport = self.controller.editState.makeRenderer().render(resolution: .full)
                }
               
                
                let source = StaticImageSource(source: convertUItoCI(from: Data.shared.neutralLUT))
            }
        }
    }
    
    func resetExport() {
        originExport = nil
    }
    
    func exportOrigin() {
        if let origin = originExport{
            ImageSaver().writeToPhotoAlbum(image: origin)
        }
        return
    }
   
}
