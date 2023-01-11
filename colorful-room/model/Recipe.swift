//
//  Recipe.swift
//  colorful-room
//
//  Created by Ping9 on 28/06/2022.
//

import Foundation
import PixelEnginePackage
import SwiftUI
import Foundation
import CoreImage
import SwiftUI

public class Recipe {
    
    public let data: RecipeObject
    public var preview:UIImage?
    
    init(data: RecipeObject){
        self.data = data
        preview = nil
    }
    ///
    public func setImage(image:CIImage?){
        
        if let cubeSourceCI: CIImage = image
        {
            let draft = EditingStack.init(source: StaticImageSource(source: cubeSourceCI))
            let colorCube:FilterColorCube? = Data.shared.cubeBy(identifier: data.lutIdentifier ?? "")
            
            draft.set(filters: RecipeUtils.applyRecipe(data, colorCube: colorCube))
            if let ciImage = draft.previewImage{
                if let cgimg = sharedContext.createCGImage(ciImage, from: ciImage.extent) {
                    self.preview = UIImage(cgImage: cgimg)
                }
            }
        }
    }
    
}

