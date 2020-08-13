//
//  SharpenControl.swift
//  colorful-room
//
//  Created by macOS on 7/13/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI
import PixelEngine

struct SharpenControl: View {
    @State var sharpnessIntensity:Double = 0
    @State var radiusIntensity:Double = 0
    
    
    var body: some View {
        
        let sharpness = Binding<Double>(
            get: {
                self.sharpnessIntensity
        },
            set: {
                self.sharpnessIntensity = $0
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
                value: sharpness,
                range: (FilterSharpen.Params.sharpness.min, FilterSharpen.Params.sharpness.max),
                 lable: "Sharpness",
                 defaultValue: 0,
                 rangeDisplay: (0, 100),
                 spacing: 8)
            FilterSlider(
                value: radius,
                range: (FilterSharpen.Params.radius.min, FilterSharpen.Params.radius.max),
                lable: "Radius",
                defaultValue: 0,
                spacing: 8)
        }
        .onAppear(perform: didReceiveCurrentEdit)
    }
    
    func didReceiveCurrentEdit() {
        
        let edit: EditingStack.Edit = PECtl.shared.edit.currentEdit
        self.sharpnessIntensity = edit.filters.sharpen?.sharpness ?? 0
        self.radiusIntensity = edit.filters.sharpen?.radius ?? 10
    }
    
    func valueChanged() {
        
        guard self.sharpnessIntensity != 0 else {
            PECtl.shared.didReceive(action: PECtl.Action.setFilter({ $0.sharpen = nil }))
            return
        }
        
        var f = FilterSharpen()
        f.sharpness = self.sharpnessIntensity
        f.radius = self.radiusIntensity
        PECtl.shared.didReceive(action: PECtl.Action.setFilter({ $0.sharpen = f }))
    }
}
