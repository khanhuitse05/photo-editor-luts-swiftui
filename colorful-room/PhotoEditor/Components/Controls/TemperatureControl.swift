//
//  TemperatureControl.swift
//  colorful-room
//
//  Created by macOS on 7/8/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI
import PixelEnginePackage

struct TemperatureControl: View {
    
    @State var filterIntensity:Double = 0
    
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
        let min = FilterTemperature.range.min
        let max = FilterTemperature.range.max
        return  FilterSlider(value: intensity, range: (min, max), defaultValue: 0)
        .onAppear(perform: didReceiveCurrentEdit)
    }
    
    func didReceiveCurrentEdit() {
        
        let edit: EditingStack.Edit = PECtl.shared.editState.currentEdit
        self.filterIntensity = edit.filters.temperature?.value ?? 0
        
    }
    
    func valueChanged() {
        
        let value = self.filterIntensity
        guard value != 0 else {
            PECtl.shared.didReceive(action: PECtlAction.setFilter({ $0.temperature = nil }))
            return
        }
        
        var f = FilterTemperature()
        f.value = value
        PECtl.shared.didReceive(action: PECtlAction.setFilter({ $0.temperature = f }))
    }
}
