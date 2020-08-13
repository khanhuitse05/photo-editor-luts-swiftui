//
//  BrightnessControl.swift
//  colorful-room
//
//  Created by macOS on 7/14/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI
import PixelEngine


// Group of:
// Fade brightness
// Saturation
// Contrast
struct ColorControl: View {
    @State var brightnessIntensity:Double = 0
    @State var saturationIntensity:Double = 0
    @State var contrastIntensity:Double = 0
    
    
    var body: some View {
        
        let brightness = Binding<Double>(
            get: {
                self.brightnessIntensity
        },
            set: {
                self.brightnessIntensity = $0
                self.valueChanged()
        }
        )
        let saturation = Binding<Double>(
            get: {
                self.saturationIntensity
        },
            set: {
                self.saturationIntensity = $0
                self.valueChanged()
        }
        )
        let contrast = Binding<Double>(
            get: {
                self.contrastIntensity
        },
            set: {
                self.contrastIntensity = $0
                self.valueChanged()
        }
        )
        
        return VStack{
            FilterSlider(
                value: brightness,
                range: (FilterColor.rangeBrightness.min, FilterColor.rangeBrightness.max),
                 lable: "Brightness",
                 defaultValue: 0,
                 rangeDisplay: (-100, 100),
                 spacing: 8)
            FilterSlider(
                value: saturation,
                range: (FilterColor.rangeSaturation.min, FilterColor.rangeSaturation.max),
                lable: "Saturation",
                defaultValue: 1,
                rangeDisplay: (-100, 100),
                spacing: 8)
            FilterSlider(
                value: contrast,
                range: (FilterColor.rangeContrast.min, FilterColor.rangeContrast.max),
                lable: "Contrast",
                defaultValue: 1,
                rangeDisplay: (-100, 100),
                spacing: 8)
        }
        .onAppear(perform: didReceiveCurrentEdit)
    }
    
    func didReceiveCurrentEdit() {
        
        let edit: EditingStack.Edit = PECtl.shared.edit.currentEdit
        self.brightnessIntensity = edit.filters.color?.valueBrightness ?? 0
        self.saturationIntensity = edit.filters.color?.valueSaturation ?? 1
        self.contrastIntensity = edit.filters.color?.valueContrast ?? 1
    }
    
    func valueChanged() {
        var f = FilterColor()
        f.valueBrightness = self.brightnessIntensity
        f.valueSaturation = self.saturationIntensity
        f.valueContrast = self.contrastIntensity
        PECtl.shared.didReceive(action: PECtl.Action.setFilter({ $0.color = f }))
    }
}
