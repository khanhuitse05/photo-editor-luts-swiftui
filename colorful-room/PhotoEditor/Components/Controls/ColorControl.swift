//
//  BrightnessControl.swift
//  colorful-room
//
//  Created by macOS on 7/14/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI
import PixelEnginePackage

struct ColorControl: View {
    @State var filterIntensity:Double = 0
    
    // Todo: Missing Saturation, Contrast
    
    var body: some View {
        
        let intensity = Binding<Double>(
            get: {
                self.filterIntensity
        },
            set: {
                self.filterIntensity = $0
                self.valueChanged()
        }
        )
        
        let min = FilterColor.rangeBrightness.min
        let max = FilterColor.rangeBrightness.max
        return  FilterSlider(value: intensity, range: (min, max), defaultValue: 0)
            .onAppear(perform: didReceiveCurrentEdit)
    }
    
    func didReceiveCurrentEdit() {
        
        let edit: EditingStack.Edit = PECtl.shared.editState.currentEdit
        self.filterIntensity = edit.filters.color?.valueBrightness ?? 0
    }
    
    func valueChanged() {
        
        let value = self.filterIntensity
        
        guard value != 0 else {
            PECtl.shared.didReceive(action: PECtlAction.setFilter({ $0.color = nil }))
            return
        }
        
        
        var f = FilterColor()
        f.valueBrightness = value
        PECtl.shared.didReceive(action: PECtlAction.setFilter({ $0.color = f }))
    }
}
