//
//  Utility.swift
//  colorful-room
//
//  Created by macOS on 7/16/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import Foundation


import UIKit
import CoreImage

let sharedContext: CIContext = {
    MetalDriverCompatibility.install()
    return CIContext(options: [.useSoftwareRenderer : false])
}()


func resizedImage(at image: CIImage, scale: CGFloat, aspectRatio: CGFloat) -> CIImage? {
    
    let filter = CIFilter(name: "CILanczosScaleTransform")
    filter?.setValue(image, forKey: kCIInputImageKey)
    filter?.setValue(scale, forKey: kCIInputScaleKey)
    filter?.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
    
    return filter?.outputImage
}


func convertUItoCI(from: UIImage) -> CIImage {
    let ciImage: CIImage
    if let ci = from.ciImage {
        ciImage = ci
    } else if let cg = from.cgImage {
        ciImage = CIImage(cgImage: cg)
    } else if let ci = CIImage(image: from) {
        ciImage = ci
    } else {
        ciImage = CIImage()
    }
    var orientedImage = ciImage.oriented(forExifOrientation: imageOrientationToTiffOrientation(from.imageOrientation))
    if orientedImage.extent.origin != .zero {
        orientedImage = orientedImage.transformed(by: CGAffineTransform(translationX: -orientedImage.extent.origin.x, y: -orientedImage.extent.origin.y))
    }
    return orientedImage
}

func imageOrientationToTiffOrientation(_ value: UIImage.Orientation) -> Int32 {
  switch value{
  case .up:
    return 1
  case .down:
    return 3
  case .left:
    return 8
  case .right:
    return 6
  case .upMirrored:
    return 2
  case .downMirrored:
    return 4
  case .leftMirrored:
    return 5
  case .rightMirrored:
    return 7
  default:
    return 1
  }
}
