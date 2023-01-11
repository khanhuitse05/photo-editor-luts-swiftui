//
//  SharpenControl.swift
//  colorful-room
//
//  Created by macOS on 7/13/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI
import PixelEnginePackage

struct SharpenControl: View {
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
        return  FilterSlider(value: intensity, range: (0, 1), defaultValue: 0, rangeDisplay: (0, 100))
        .onAppear(perform: didReceiveCurrentEdit)
    }
    
    func didReceiveCurrentEdit() {
        
        let edit: EditingStack.Edit = PECtl.shared.editState.currentEdit
        self.filterIntensity = edit.filters.sharpen?.sharpness ?? 0
    }
    
    func valueChanged() {
        
        let value = self.filterIntensity
        
        guard value != 0 else {
            PECtl.shared.didReceive(action: PECtlAction.setFilter({ $0.sharpen = nil }))
            return
        }
        
        var f = FilterSharpen()
        f.sharpness = value
        PECtl.shared.didReceive(action: PECtlAction.setFilter({ $0.sharpen = f }))
    }
}
