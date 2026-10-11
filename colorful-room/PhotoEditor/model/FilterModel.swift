//
//  FilterModel.swift
//  colorful-room
//
//  Created by Ping9 on 26/09/2021.
//  Copyright © 2021 PingAK9. All rights reserved.
//

import Foundation

public enum EditMenu: Sendable {
    case none
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

public struct FilterModel: Sendable, Equatable {
    
    var name: String
    var image: String
    var edit: EditMenu
    
    static let noneFilterModel = FilterModel("", edit: EditMenu.none)
    
    init(_ name: String, image: String = "", edit: EditMenu) {
        self.name = name
        if image.isEmpty {
            self.image = name.lowercased()
        } else {
            self.image = image
        }
        self.edit = edit
    }
}
