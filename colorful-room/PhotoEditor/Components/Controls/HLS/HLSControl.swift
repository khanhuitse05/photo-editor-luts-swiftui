//
//  HLSControl.swift
//  colorful-room
//
//  Created by macOS on 7/8/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI
import PixelEnginePackage

struct HLSControl: View {
    
    static var colors:[Color] = [
        Color(red: 0.8980392156862745, green: 0, blue: 0),
        Color(red: 0.9764705882352941, green: 0.45098039215686275, blue: 0.023529411764705882),
        Color(red: 1, green: 1, blue: 0.0784313725490196),
        Color(red: 0.08235294117647059, green: 0.6901960784313725, blue: 0.10196078431372549),
        Color(red: 0.07450980392156863, green: 0.9176470588235294, blue: 0.788235294117647),
        Color(red: 0.011764705882352941, green: 0.2627450980392157, blue: 0.8745098039215686),
        Color(red: 0.49411764705882355, green: 0.11764705882352941, blue: 0.611764705882353),
        Color(red: 0.7607843137254902, green: 0, blue: 0.47058823529411764),
    ]
    
    @State var current:Int = 0
    @State var hue:Double = 0.5
    @State var saturation:Double = 0.5
    @State var luminance:Double = 0.5
    
    @State  var inputShift:[CIVector]!
    
    var body: some View {
        
        let indexCurent = Binding<Int>(
            get: {
                self.current
        },
            set: {
                self.current = $0
                self.colorChange()
        }
        )
        
        let intensityHeu = Binding<Double>(
            get: {
                self.hue
        },
            set: {
                self.hue = $0
                self.valueChanged()
        }
        )
        let intensitySaturation = Binding<Double>(
            get: {
                self.saturation
        },
            set: {
                self.saturation = $0
                self.valueChanged()
        }
        )
        let intensityLuminance = Binding<Double>(
            get: {
                self.luminance
        },
            set: {
                self.luminance = $0
                self.valueChanged()
        }
        )
        
        return VStack(alignment: .leading){
            HStack{
                ForEach(0...HLSControl.colors.count - 1, id: \.self){index in
                    HStack{
                        Spacer()
                        ColorSelectButton(index: index, current: indexCurent)
                        Spacer()
                    }
                }
            }
            Spacer()
            FilterSlider(value: intensityHeu, range: (-0.2, 0.2), lable: "Hue", defaultValue: 0)
            FilterSlider(value: intensitySaturation, range: (0, 2), lable: "Saturation", defaultValue: 1)
            FilterSlider(value: intensityLuminance, range: (0.5, 1.5), lable: "Luminance", defaultValue: 1)
            Spacer()
        }
        .onAppear(perform: didReceiveCurrentEdit)
    }
    
    func didReceiveCurrentEdit() {
        let edit: EditingStack.Edit = PECtl.shared.editState.currentEdit
        guard let hsv:FilterHLS = edit.filters.hls else{
            self.inputShift = FilterHLS.defaultValue
            print("hsv NULL")
            colorChange()
            return
        }
        self.inputShift = hsv.inputShift
        colorChange()
        
    }
    
    func colorChange(){
        print("colorChange")
        let currentShift:CIVector = self.inputShift[current]
        hue = Double(currentShift.x)
        saturation = Double(currentShift.y)
        luminance = Double(currentShift.z)
    }
    
    func valueChanged() {
        self.inputShift[current] = CIVector(x: CGFloat(hue), y: CGFloat(saturation), z: CGFloat(luminance))
        
        var hsv = FilterHLS()
        hsv.inputShift = self.inputShift
        PECtl.shared.didReceive(action: PECtlAction.setFilter({ $0.hls = hsv }))
    }
}
