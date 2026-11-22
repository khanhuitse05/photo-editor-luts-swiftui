//
//  RecipeModel.swift
//  colorful-room
//
//  Created by Ping9 on 15/01/2022.
//

import Foundation
@preconcurrency import PixelEnginePackage
import UIKit
import Combine
import SwiftUI
import QCropper
import CoreData
import os

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "colorful-room", category: "RecipeUtils")

public class RecipeUtils {
    
    private static var container: NSPersistentContainer {
        PersistenceController.shared.container
    }
    
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
        let contrast: FilterContrast? = data.contrast != 0 ? {
            var f = FilterContrast()
            f.value = data.contrast
            return f
        }() : nil

        let saturation: FilterSaturation? = data.saturation != 0 ? {
            var f = FilterSaturation()
            f.value = data.saturation
            return f
        }() : nil

        let exposure: FilterExposure? = data.exposure != 0 ? {
            var f = FilterExposure()
            f.value = data.exposure
            return f
        }() : nil

        let highlights: FilterHighlights? = data.highlights != 0 ? {
            var f = FilterHighlights()
            f.value = data.highlights
            return f
        }() : nil

        let shadows: FilterShadows? = data.shadows != 0 ? {
            var f = FilterShadows()
            f.value = data.shadows
            return f
        }() : nil

        let temperature: FilterTemperature? = data.temperature != 0 ? {
            var f = FilterTemperature()
            f.value = data.temperature
            return f
        }() : nil

        let gaussianBlur: FilterGaussianBlur? = data.gaussianBlur != 0 ? {
            var f = FilterGaussianBlur()
            f.value = data.gaussianBlur
            return f
        }() : nil

        let vignette: FilterVignette? = data.vignette != 0 ? {
            var f = FilterVignette()
            f.value = data.vignette
            return f
        }() : nil

        let fade: FilterFade? = data.fade != 0 ? {
            var f = FilterFade()
            f.intensity = data.fade
            return f
        }() : nil

        let whiteBalance: FilterWhiteBalance? = (data.whiteBalanceTemperature != 0 || data.whiteBalanceTint != 0) ? {
            var f = FilterWhiteBalance()
            f.valueTemperature = data.whiteBalanceTemperature
            f.valueTint = data.whiteBalanceTint
            return f
        }() : nil

        var appliedColorCube: FilterColorCube? = colorCube
        appliedColorCube?.amount = data.lutAmount

        // CoreData defaults leave colorValueSaturation and colorValueContrast at 0.0 when unset.
        // Treat (0, 0, 0) as unset rather than applying a zero-contrast solid-gray filter.
        let hasCustomColor = data.colorValueBrightness != 0
            || (data.colorValueSaturation != 0 && data.colorValueSaturation != 1)
            || (data.colorValueContrast != 0 && data.colorValueContrast != 1)
        let color: FilterColor? = hasCustomColor ? {
            var f = FilterColor()
            f.valueSaturation = data.colorValueSaturation == 0 ? 1 : data.colorValueSaturation
            f.valueBrightness = data.colorValueBrightness
            f.valueContrast = data.colorValueContrast == 0 ? 1 : data.colorValueContrast
            return f
        }() : nil

        let sharpen: FilterSharpen? = (data.sharpenSharpness != 0 || data.sharpenRadius != 0) ? {
            var f = FilterSharpen()
            f.sharpness = data.sharpenSharpness
            f.radius = data.sharpenRadius
            return f
        }() : nil

        let unsharpMask: FilterUnsharpMask? = (data.unsharpMaskIntensity != 0 || data.unsharpMaskRadius != 0) ? {
            var f = FilterUnsharpMask()
            f.intensity = data.unsharpMaskIntensity
            f.radius = data.unsharpMaskRadius
            return f
        }() : nil

        let hls: FilterHLS?
        if RecipeUtils.hasCustomHLS(data.hls) {
            var customHLS = FilterHLS()
            customHLS.inputShift = RecipeUtils.stringToArrayVector(data.hls ?? "")
            hls = customHLS
        } else {
            hls = nil
        }

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
            $0.colorCube = appliedColorCube
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

    /// Checks whether an HLS string contains custom (non-default) shifts.
    static func hasCustomHLS(_ value: String?) -> Bool {
        guard let value = value, !value.isEmpty else { return false }
        let vectors = stringToArrayVector(value)
        let defaults = FilterHLS.defaultValue
        guard vectors.count == defaults.count else { return true }
        for (v, d) in zip(vectors, defaults) {
            if abs(v.x - d.x) > 0.001 || abs(v.y - d.y) > 0.001 || abs(v.z - d.z) > 0.001 {
                return true
            }
        }
        return false
    }

    ///
    static func stringToArrayVector(_ value:String) -> [CIVector] {
        if(value.isEmpty){
            return FilterHLS.defaultValue;
        }
        // vectorFromString — parse with locale-independent Double() since arrayVectorToString uses "."
        func vectorFromString(_ text:String)-> CIVector{
            func floatOf(_ text:String)-> CGFloat{
                guard let number = Double(text.trimmingCharacters(in: .whitespaces)) else {
                    return 0
                }
                return CGFloat(number)
            }
            let items = text.components(separatedBy: ",")
            guard items.count >= 3 else {
                return CIVector(x: 0, y: 1, z: 1)
            }
            return CIVector(x: floatOf(items[0]), y: floatOf(items[1]), z: floatOf(items[2]))
        }
        //
        var result:[CIVector] = FilterHLS.defaultValue
        let vectors = value.components(separatedBy: ";")
        for (i, text) in vectors.enumerated() where i < result.count {
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
