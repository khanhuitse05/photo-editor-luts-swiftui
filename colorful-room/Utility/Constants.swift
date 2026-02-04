//
//  Constants.swift
//  colorful-room
//
//  Created by Ping9 on 16/01/2022.
//

import Foundation

public class Constants{
    static var supportFilters:[FilterModel] = [
        FilterModel("Brightness", edit: EditMenu.exposure),
        FilterModel("Contrast", edit: EditMenu.contrast),
        FilterModel("Saturation", edit: EditMenu.saturation),
        FilterModel("White Blance",image:"temperature", edit: EditMenu.white_balance),
        FilterModel("Tone",image: "tone", edit: EditMenu.tone),
        FilterModel("HSL",image: "hls", edit: EditMenu.hls),
        FilterModel("Fade", edit: EditMenu.fade),
    ]
}
