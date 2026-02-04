//
//  Collection.swift
//  colorful-room
//
//  Created by macOS on 7/15/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import Foundation
import PixelEnginePackage
import SwiftUI

public class Collection {
    
    public let name: String
    public let identifier: String
    public var cubeInfos:[FilterColorCubeInfo]
    public var cubePreviews:[PreviewFilterColorCube] = []
    
    ///
    public func setImage(image:CIImage?){
        self.cubePreviews = []
        if let cubeSourceCI: CIImage = image
        {
            for item in cubeInfos {
                let cube = FilterColorCube(name: item.name, identifier: item.identifier, lutImage: UIImage(named: item.lutImage)!, dimension: 64);
                let preview = PreviewFilterColorCube(sourceImage: cubeSourceCI, filter: cube)
                cubePreviews.append(preview)
                
            }
        }
    }
    
    ///
    public func reset(){
        cubePreviews = []
    }
    
    ///
    public init(
        name: String,
        identifier: String,
        cubeInfos: [FilterColorCubeInfo] = []
    ) {
        self.name = name
        self.identifier = identifier
        self.cubeInfos = cubeInfos
    }
    
}


public struct FilterColorCubeInfo : Equatable {
    public let name: String
    public let identifier: String
    public let lutImage:String
    
    public init(
        name: String,
        identifier: String,
        lutImage: String
    ) {
        self.name = name
        self.identifier = identifier
        self.lutImage = lutImage
    }
    
    func getFilter()-> FilterColorCube{
        return FilterColorCube(name: name, identifier: identifier, lutImage: UIImage(named: lutImage)!, dimension: 64)
    }
    
}
