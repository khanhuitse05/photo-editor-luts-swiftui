//
//  TemperatureControl.swift
//  colorful-room
//
//  Created by macOS on 7/8/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI
import PixelEnginePackage

struct WhiteBalanceControl: View {
    
    @State var temperatureIntensity:Double = 0
    
    @State var tintIntensity:Double = 0
    
    var body: some View {
        
        let temperature = Binding<Double>(
            get: {
                self.temperatureIntensity
        },
            set: {
                self.temperatureIntensity = $0
                self.valueChanged()
        }
        )
        let tint = Binding<Double>(
            get: {
                self.tintIntensity
        },
            set: {
                self.tintIntensity = $0
                self.valueChanged()
        }
        )
        return VStack(spacing: 24){
            FilterSlider(value: temperature, range: (FilterWhiteBalance.range.min, FilterWhiteBalance.range.max), lable: "Temperature", defaultValue: 0, spacing: 8)
            
            FilterSlider(value: tint, range: (FilterWhiteBalance.range.min, FilterWhiteBalance.range.max),lable: "Tint", defaultValue: 0, spacing: 8)
        }
        .onAppear(perform: didReceiveCurrentEdit)
    }
    
    func didReceiveCurrentEdit() {
        
        let edit: EditingStack.Edit = PECtl.shared.editState.currentEdit
        self.temperatureIntensity = edit.filters.whiteBalance?.valueTemperature ?? 0
        self.tintIntensity = edit.filters.whiteBalance?.valueTint ?? 0
        
    }
    
    func valueChanged() {
        
        let valueTemperature = self.temperatureIntensity
        
        let valueTint = self.tintIntensity
        if (valueTemperature == 0 && valueTint == 0) {
            PECtl.shared.didReceive(action: PECtlAction.setFilter({ $0.whiteBalance = nil }))
            return
        }
        
        var f = FilterWhiteBalance()
        f.valueTint = valueTint
        f.valueTemperature = valueTemperature
        PECtl.shared.didReceive(action: PECtlAction.setFilter({ $0.whiteBalance = f }))
    }
}
