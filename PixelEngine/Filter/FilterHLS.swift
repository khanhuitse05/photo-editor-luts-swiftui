//
//  FilterHLS.swift
//  PixelEngine
//
//  Created by macOS on 7/7/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import Foundation
import CoreImage

public struct FilterHLS : Filtering, Equatable {
    
    public static var defaultValue:[CIVector] = [ CIVector(x: 0, y: 1, z: 1),
                                                  CIVector(x: 0, y: 1, z: 1),
                                                  CIVector(x: 0, y: 1, z: 1),
                                                  CIVector(x: 0, y: 1, z: 1),
                                                  CIVector(x: 0, y: 1, z: 1),
                                                  CIVector(x: 0, y: 1, z: 1),
                                                  CIVector(x: 0, y: 1, z: 1),
                                                  CIVector(x: 0, y: 1, z: 1),]
    
    public var inputShift:[CIVector] = FilterHLS.defaultValue
    
    
    public init() {
        
    }
    
    public func apply(to image: CIImage, sourceImage: CIImage) -> CIImage {
        
        let hsv:MultiBandHSV = MultiBandHSV()
        hsv.inputImage = image
        hsv.inputRedShift = inputShift[0]
        hsv.inputOrangeShift = inputShift[1]
        hsv.inputYellowShift = inputShift[2]
        hsv.inputGreenShift = inputShift[3]
        hsv.inputAquaShift = inputShift[4]
        hsv.inputBlueShift = inputShift[5]
        hsv.inputPurpleShift = inputShift[6]
        hsv.inputMagentaShift = inputShift[7]
        return hsv.outputImage!
    }
    
}
