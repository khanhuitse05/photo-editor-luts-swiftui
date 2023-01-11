//
//  ToneControl.swift
//  colorful-room
//
//  Created by macOS on 7/17/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI
import PixelEnginePackage

struct ToneControl: View {
    
    @State var highlightIntensity:Double = 0
    
    @State var shadowIntensity:Double = 0
    
    var body: some View {
        
        let highlight = Binding<Double>(
            get: {
                self.highlightIntensity
        },
            set: {
                self.highlightIntensity = $0
                self.valueHighlightChanged()
        }
        )
        let shadow = Binding<Double>(
            get: {
                self.shadowIntensity
        },
            set: {
                self.shadowIntensity = $0
                self.valueShadowChanged()
        }
        )
        return VStack(spacing: 24){
            FilterSlider(value: highlight, range: (FilterHighlights.range.min, FilterHighlights.range.max), lable: "Highlights", defaultValue: 0, rangeDisplay: (0, 100), spacing: 8)
            
            FilterSlider(value: shadow, range: (FilterShadows.range.min, FilterShadows.range.max),lable: "Shadows", defaultValue: 0, spacing: 8)
        }
        .onAppear(perform: didReceiveCurrentEdit)
    }
    
    func didReceiveCurrentEdit() {
        
        let edit: EditingStack.Edit = PECtl.shared.editState.currentEdit
        self.highlightIntensity = edit.filters.highlights?.value ?? 0
        self.shadowIntensity = edit.filters.shadows?.value ?? 0
        
    }
    
    func valueHighlightChanged() {
        
        let value = self.highlightIntensity
        guard value != 0 else {
            PECtl.shared.didReceive(action: PECtlAction.setFilter({ $0.highlights = nil }))
            return
        }
        
        var f = FilterHighlights()
        f.value = value
        PECtl.shared.didReceive(action: PECtlAction.setFilter({ $0.highlights = f }))
    }
    func valueShadowChanged() {
        
        let value = self.shadowIntensity
        guard value != 0 else {
            PECtl.shared.didReceive(action: PECtlAction.setFilter({ $0.shadows = nil }))
            return
        }
        
        var f = FilterShadows()
        f.value = value
        PECtl.shared.didReceive(action: PECtlAction.setFilter({ $0.shadows = f }))
    }
}
