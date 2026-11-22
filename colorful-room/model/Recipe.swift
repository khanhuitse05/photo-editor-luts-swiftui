//
//  Recipe.swift
//  colorful-room
//
//  Created by Ping9 on 28/06/2022.
//

import Foundation
import Observation
import PixelEnginePackage
import SwiftUI
import CoreImage

@MainActor
@Observable
public class Recipe {

    public let data: RecipeObject
    public var preview: UIImage?

    init(data: RecipeObject) {
        self.data = data
        preview = nil
    }

    /// Renders a thumbnail preview of the recipe applied to the given image.
    public func setImage(image: CIImage?) {
        guard let cubeSourceCI = image else {
            self.preview = nil
            return
        }
        let draft = EditingStack(source: StaticImageSource(source: cubeSourceCI))
        let colorCube: FilterColorCube? = Data.shared.cubeBy(identifier: data.lutIdentifier ?? "")

        draft.set(filters: RecipeUtils.applyRecipe(data, colorCube: colorCube))
        if let ciImage = draft.previewImage {
            let extent = ciImage.extent.isInfinite ? cubeSourceCI.extent : ciImage.extent
            guard !extent.isEmpty else { return }
            if let cgimg = sharedContext.createCGImage(ciImage, from: extent) {
                self.preview = UIImage(cgImage: cgimg)
            }
        }
    }
}

