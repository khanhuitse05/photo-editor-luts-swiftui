//
//  EditMenu.swift
//  colorful-room
//
//  Created by Ping9 on 8/13/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import Foundation

public enum EditMenu {
    case none
    case adjustment
    case mask
    case exposure
    case contrast
    case clarity
    case temperature
    case saturation
    case fade
    case highlights
    case shadows
    case vignette
    case sharpen
    case gaussianBlur
    case color
    case hls
    case tone
    case white_balance
}

var noneFilterModel:FilterModel = FilterModel("", edit: EditMenu.none)

class FilterModel{
    
    var name:String
    var image:String
    var edit:EditMenu
    
    init(_ name:String, image:String = "", edit:EditMenu) {
        self.name = name
        if(image.isEmpty){
            self.image = name.lowercased()
        }else{
            self.image = image
        }
        self.edit = edit
    }
}
