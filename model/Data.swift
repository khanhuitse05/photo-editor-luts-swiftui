//
//  EditController.swift
//  test
//
//  Created by macOS on 7/2/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import Foundation
import SwiftUI
import PixelEnginePackage

class Data: ObservableObject {
    
    static var shared = Data();
    
    var collections:[Collection]!
    var neutralLUT: UIImage!
    
    init(){
        autoreleasepool {
            
            // basic
            let basic = Collection(name: "Basic", identifier: "Basic", cubeInfos: [])
            for i in 1...10{
                let cube =  FilterColorCubeInfo(
                    name: "A\(i)",
                    identifier: "basic-\(i)",
                    lutImage: "lut-\(i)"
                )
                basic.cubeInfos.append(cube)
            }
            // Cinematic
            let cinematic = Collection(name: "Cinematic", identifier: "Cinematic", cubeInfos: [])
            for i in 1...4{
                let cube =  FilterColorCubeInfo(
                    name: "C\(i)",
                    identifier: "Cinematic-\(i)",
                    lutImage: "cinematic-\(i)"
                )
                cinematic.cubeInfos.append(cube)
            }
            // Film
            let film = Collection(name: "Film", identifier: "Film", cubeInfos: [])
            for i in 1...3{
                let cube =  FilterColorCubeInfo(
                    name: "Film\(i)",
                    identifier: "Film-\(i)",
                    lutImage: "film-\(i)"
                )
                film.cubeInfos.append(cube)
            }
            // Selfie Good Skin
            let selfie = Collection(name: "Selfie", identifier: "Selfie", cubeInfos: [])
            for i in 1...5{
                let cube =  FilterColorCubeInfo(
                    name: "Selfie\(i)",
                    identifier: "Selfie-\(i)",
                    lutImage: "selfie-\(i)"
                )
                selfie.cubeInfos.append(cube)
            }
            // init collections
            self.collections = [basic, cinematic, film, selfie]
        }
    }
    
    
}
