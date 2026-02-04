//
//  RecipeModel.swift
//  colorful-room
//
//  Created by Ping9 on 15/01/2022.
//

import Foundation
import PixelEnginePackage
import UIKit
import Foundation
import Combine
import SwiftUI
import PixelEnginePackage
import QCropper
import CoreData

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
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return []
    }
    
    static func applyRecipe(_ data:RecipeObject, colorCube:FilterColorCube?) ->  (inout EditingStack.Edit.Filters) -> Void{
        
        print(data)
        
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
          print("Could not save. \(error), \(error.userInfo)")
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
          print("Could not save. \(error), \(error.userInfo)")
        }
        return false
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
