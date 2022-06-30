//
//  ColorCubeControl.swift
//  colorful-room
//
//  Created by macOS on 7/20/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI
import PixelEnginePackage

struct ColorCubeControl: View {
    
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
        return  FilterSlider(value: intensity, range: (0, 1), defaultValue: 0, rangeDisplay: (0, 100)).onAppear(perform: didReceiveCurrentEdit)
    }
    
    func didReceiveCurrentEdit() {
        
        let edit: EditingStack.Edit = PECtl.shared.editState.currentEdit
        self.filterIntensity = edit.filters.colorCube?.amount ?? 1
    }
    
    func valueChanged() {
        
        guard let filter: FilterColorCube =  PECtl.shared.editState.currentEdit.filters.colorCube else {
            return
        }
        
        let value = self.filterIntensity
        let clone:FilterColorCube = FilterColorCube(name: filter.name, identifier: filter.identifier, filter: filter.filter, amount: value)
       
        PECtl.shared.didReceive(action: PECtlAction.setFilter({ $0.colorCube = clone }))
    }
}
