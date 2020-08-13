//
//  SharpenControl.swift
//  colorful-room
//
//  Created by macOS on 7/13/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI
import PixelEngine

struct UnsharpMaskControl: View {
    @State var valueIntensity:Double = 0
    @State var radiusIntensity:Double = 0
    
    
    var body: some View {
        
        let value = Binding<Double>(
            get: {
                self.valueIntensity
        },
            set: {
                self.valueIntensity = $0
                self.valueChanged()
        }
        )
        let radius = Binding<Double>(
            get: {
                self.radiusIntensity
        },
            set: {
                self.radiusIntensity = $0
                self.valueChanged()
        }
        )
        return  VStack{
            FilterSlider(
                value: value,
                range: (FilterUnsharpMask.Params.intensity.min, FilterUnsharpMask.Params.intensity.max),
                 lable: "Intensity",
                 defaultValue: 0,
                 rangeDisplay: (0, 100),
                 spacing: 8)
            FilterSlider(
                value: radius,
                range: (FilterUnsharpMask.Params.radius.min, FilterUnsharpMask.Params.radius.max),
                lable: "Radius",
                defaultValue: 0,
                rangeDisplay: (0, 20),
                spacing: 8)
        }
        .onAppear(perform: didReceiveCurrentEdit)
    }
    
    func didReceiveCurrentEdit() {
        let edit: EditingStack.Edit = PECtl.shared.edit.currentEdit
        self.valueIntensity = edit.filters.unsharpMask?.intensity ?? 0
        self.radiusIntensity = edit.filters.unsharpMask?.radius ?? 0.5
    }
    
    func valueChanged() {
        
        guard self.radiusIntensity != 0 || self.valueIntensity != 0 else {
            PECtl.shared.didReceive(action: PECtl.Action.setFilter({ $0.sharpen = nil }))
            return
        }
        
        var f = FilterUnsharpMask()
        f.intensity = self.valueIntensity
        f.radius = self.radiusIntensity
        PECtl.shared.didReceive(action: PECtl.Action.setFilter({ $0.unsharpMask = f }))
    }
}
