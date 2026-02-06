//
//  RecipeModel.swift
//  colorful-room
//
//  Created by Ping9 on 15/01/2022.
//

import Foundation
import PixelEnginePackage
import UIKit
import Combine
import SwiftUI
import QCropper
import CoreData
import os

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "colorful-room", category: "RecipeUtils")

public class RecipeUtils {
    
    private static var container = PersistenceController.shared.container;
    
    // Load recipe from locale
    static func loadRecipe() -> [RecipeObject]{
       
        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "RecipeObject")

        //3
        do {
            let result:[RecipeObject] = try container.viewContext.fetch(fetchRequest) as! [RecipeObject]
            return result
        } catch let error as NSError {
            logger.error("Could not fetch recipes: \(error), \(error.userInfo)")
        }
        return []
    }
    
    static func applyRecipe(_ data:RecipeObject, colorCube:FilterColorCube?) ->  (inout EditingStack.Edit.Filters) -> Void{
        
        var contrast = FilterContrast()
        contrast.value = data.contrast
        
        var saturation = FilterSaturation()
        saturation.value = data.saturation
        
        var exposure = FilterExposure()
        exposure.value = data.exposure
        
        var highlights = FilterHighlights()
        highlights.value = data.highlights
        
        var shadows = FilterShadows()
        shadows.value = data.shadows
        
        var temperature = FilterTemperature()
        temperature.value = data.temperature
        
        var gaussianBlur = FilterGaussianBlur()
        gaussianBlur.value = data.gaussianBlur
        
        var vignette = FilterVignette()
        vignette.value = data.vignette
        
        var fade = FilterFade()
        fade.intensity = data.fade
        
        var whiteBalance = FilterWhiteBalance()
        whiteBalance.valueTemperature = data.whiteBalanceTemperature
        whiteBalance.valueTint = data.whiteBalanceTint

        var colorCube:FilterColorCube? = colorCube
        colorCube?.amount = data.lutAmount
        
        var color = FilterColor()
        color.valueSaturation = data.colorValueSaturation
        color.valueBrightness = data.colorValueBrightness
        color.valueContrast = data.colorValueContrast
        
        var sharpen = FilterSharpen()
        sharpen.sharpness = data.sharpenSharpness
        sharpen.radius = data.sharpenRadius
        
        var unsharpMask = FilterUnsharpMask()
        unsharpMask.intensity = data.unsharpMaskIntensity
        unsharpMask.radius = data.unsharpMaskRadius
        
        var hls = FilterHLS()
        hls.inputShift = RecipeUtils.stringToArrayVector(data.hls ?? "")
        
        return {
            $0.contrast = contrast
            $0.saturation = saturation
            $0.exposure = exposure
            $0.highlights = highlights
            $0.shadows = shadows
            $0.temperature = temperature
            $0.gaussianBlur = gaussianBlur
            $0.vignette = vignette
            $0.fade = fade
            $0.whiteBalance = whiteBalance
            $0.colorCube = colorCube
            $0.color = color
            $0.sharpen = sharpen
            $0.unsharpMask = unsharpMask
            $0.hls = hls
        };
    }
    
    ///
    static func addRecipe(_ name: String, filters: EditingStack.Edit.Filters)-> RecipeObject?{
        
        let item = RecipeObject(context: container.viewContext)
        
        item.recipeName = name
        // simple filter
        item.contrast = filters.contrast?.value ?? 0.0
        item.saturation = filters.saturation?.value ?? 0.0
        item.exposure = filters.exposure?.value ?? 0.0
        item.highlights = filters.highlights?.value ?? 0.0
        item.shadows = filters.shadows?.value ?? 0.0
        item.temperature = filters.temperature?.value ?? 0.0
        item.gaussianBlur = filters.gaussianBlur?.value ?? 0.0
        item.vignette = filters.vignette?.value ?? 0.0
        item.fade = filters.fade?.intensity ?? 0.0
        // whiteBalance
        item.whiteBalanceTemperature = filters.whiteBalance?.valueTemperature ?? 0.0
        item.whiteBalanceTint = filters.whiteBalance?.valueTint ?? 0.0
        // colorCube
        item.lutIdentifier = filters.colorCube?.identifier ?? ""
        item.lutAmount = filters.colorCube?.amount ?? 1
        // color
        item.colorValueSaturation = filters.color?.valueSaturation ?? 1
        item.colorValueBrightness = filters.color?.valueBrightness ?? 0
        item.colorValueContrast = filters.color?.valueContrast ?? 1
        // sharpen
        item.sharpenSharpness = filters.sharpen?.sharpness ?? 0
        item.sharpenRadius = filters.sharpen?.radius ?? 0
        // unsharpMask
        item.unsharpMaskIntensity = filters.unsharpMask?.intensity ?? 0
        item.unsharpMaskRadius = filters.unsharpMask?.radius ?? 0
        // hls
        item.hls = arrayVectorToString(filters.hls?.inputShift)
        
        // 4
        
        do {
          try container.viewContext.save()
            return item
        } catch let error as NSError {
          logger.error("Could not save recipe: \(error), \(error.userInfo)")
        }
        return nil
    }
    
    ///
    static func deleteRecipe(_ item:RecipeObject)-> Bool{
        container.viewContext.delete(item)
    
        do {
          try container.viewContext.save()
            return true
        } catch let error as NSError {
          logger.error("Could not delete recipe: \(error), \(error.userInfo)")
        }
        return false
    }

    /// Renames an existing recipe.
    static func renameRecipe(_ item: RecipeObject, to newName: String) -> Bool {
        item.recipeName = newName
        do {
            try container.viewContext.save()
            return true
        } catch let error as NSError {
            logger.error("Could not rename recipe: \(error), \(error.userInfo)")
        }
        return false
    }

    /// Duplicates an existing recipe with a new name.
    static func duplicateRecipe(_ item: RecipeObject, name: String) -> RecipeObject? {
        let newItem = RecipeObject(context: container.viewContext)
        newItem.recipeName = name
        // Simple filters
        newItem.contrast = item.contrast
        newItem.saturation = item.saturation
        newItem.exposure = item.exposure
        newItem.highlights = item.highlights
        newItem.shadows = item.shadows
        newItem.temperature = item.temperature
        newItem.gaussianBlur = item.gaussianBlur
        newItem.vignette = item.vignette
        newItem.fade = item.fade
        // White balance
        newItem.whiteBalanceTemperature = item.whiteBalanceTemperature
        newItem.whiteBalanceTint = item.whiteBalanceTint
        // Color cube / LUT
        newItem.lutIdentifier = item.lutIdentifier
        newItem.lutAmount = item.lutAmount
        // Color
        newItem.colorValueSaturation = item.colorValueSaturation
        newItem.colorValueBrightness = item.colorValueBrightness
        newItem.colorValueContrast = item.colorValueContrast
        // Sharpen
        newItem.sharpenSharpness = item.sharpenSharpness
        newItem.sharpenRadius = item.sharpenRadius
        // Unsharp mask
        newItem.unsharpMaskIntensity = item.unsharpMaskIntensity
        newItem.unsharpMaskRadius = item.unsharpMaskRadius
        // HLS
        newItem.hls = item.hls

        do {
            try container.viewContext.save()
            return newItem
        } catch let error as NSError {
            logger.error("Could not duplicate recipe: \(error), \(error.userInfo)")
        }
        return nil
    }

    ///
    static func stringToArrayVector(_ value:String) -> [CIVector] {
        if(value.isEmpty){
            return FilterHLS.defaultValue;
        }
        // vectorFromString
        func vectorFromString(_ text:String)-> CIVector{
            // floatFromString
            func floatOf(_ text:String)-> CGFloat{
                guard let number = NumberFormatter().number(from: text) else {
                    return 0
                }
                return CGFloat(number.floatValue)
            }
            let items = text.components(separatedBy: ",")
            let result = CIVector(x: floatOf(items[0]), y: floatOf(items[1]), z: floatOf(items[2]))
            return result
        }
        //
        var result:[CIVector] = FilterHLS.defaultValue
        let vectors = value.components(separatedBy: ";")
        vectors.enumerated().forEach { (i, text) in
            result[i] = vectorFromString(text)
        }
        return result
    }
    
    ///
    static func arrayVectorToString(_ value:[CIVector]?) -> String {
        if(value == nil){
            return ""
        }
        var result:String = ""
        for e in value! {
            if(result.isEmpty == false){
                result += ";"
            }
            result += "\(e.x),\(e.y),\(e.z)"
        }
        return result
    }
    
}
