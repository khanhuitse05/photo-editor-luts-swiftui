//
//  IconButton.swift
//  colorful-room
//
//  Created by macOS on 7/15/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct IconButton: View {
    var image:String
    var size:CGFloat
    
    init(_ image:String, size:CGFloat = 32) {
        self.image = image
        self.size = size
    }
    var body: some View {
        if let uiImage = UIImage(named: self.image) {
            Image(uiImage: uiImage)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: self.size, height: self.size)
        } else {
            Image(systemName: systemIconName(for: self.image))
                .font(.system(size: self.size * 0.7, weight: .regular))
                .foregroundStyle(.primary)
                .frame(width: self.size, height: self.size)
        }
    }
    
    private func systemIconName(for name: String) -> String {
        switch name.lowercased() {
        case "highlights": return "circle.lefthalf.striped.horizontal"
        case "shadows": return "circle.lefthalf.filled"
        case "sharpen": return "triangle"
        case "vignette": return "circle.dashed.inset.filled"
        case "blur", "gaussianblur": return "drop.halffull"
        case "clarity": return "wand.and.rays"
        case "brightness", "exposure": return "sun.max"
        case "contrast": return "circle.righthalf.filled"
        case "saturation": return "drop.triangle"
        case "temperature", "white-balance", "white_balance": return "thermometer.sun"
        case "tone": return "dial.low"
        case "hls": return "paintpalette"
        case "fade": return "slider.horizontal.below.rectangle"
        default: return "slider.horizontal.3"
        }
    }
}
