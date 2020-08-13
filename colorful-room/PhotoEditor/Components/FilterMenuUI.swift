//
//  FilterMenuView.swift
//  colorful-room
//
//  Created by macOS on 7/14/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct FilterMenuUI: View {
    
    @EnvironmentObject var shared:PECtl
    
    var body: some View {
        ZStack{
            
            VStack{
                Spacer()
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 16){
                        Spacer().frame(width: 0)
                        ForEach(shared.filters, id: \.name) { filter in
                            ButtonView(action: filter)
                        }
                        Spacer().frame(width: 0)
                    }
                }
                Spacer()
                Text("Edit Color")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.myGrayLight)
                    .padding(.bottom, 8)
            }
            if shared.currentFilter.edit != .none {
                VStack{
                    Spacer()
                    if shared.index == .color {
                        ColorControl()
                    }else if shared.index == .contrast {
                        ContrastControl()
                    }else if shared.index == .vignette {
                        VignetteControl()
                    }else if shared.index == .fade {
                        FadeControl()
                    }else if shared.index == .highlights {
                        HighlightsControl()
                    }else if shared.index == .hls {
                        HLSControl()
                    }else if shared.index == .exposure {
                        ExposureControl()
                    }else if shared.index == .saturation {
                        SaturationControl()
                    }else if shared.index == .shadows {
                        ShadowsControl()
                    }else if shared.index == .sharpen {
                        SharpenControl()
                    }else if shared.index == .temperature {
                        TemperatureControl()
                    }else if shared.index == .vignette {
                        VignetteControl()
                    }else if shared.index == .tone {
                        ToneControl()
                    }else if shared.index == .clarity {
                        UnsharpMaskControl()
                    }else if shared.index == .white_balance {
                        WhiteBalanceControl()
                    }else if shared.index == .gaussianBlur {
                        GaussianBlurControl()
                    }else{
                        Text("Todo")
                    }
                    
                    Spacer()
                    HStack{
                        Button(action: {
                            self.shared.didReceive(action: PECtl.Action.revert)
                            self.shared.currentFilter = noneFilterModel
                        }){
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Text(shared.currentFilter.name)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.myGrayLight)
                        Spacer()
                        Button(action: {
                            self.shared.didReceive(action: PECtl.Action.commit)
                            self.shared.currentFilter = noneFilterModel
                        }){
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        }
                    }.padding(.bottom, 8)
                }
                .padding(.horizontal)
                .background(Color.myBackground)
            }
            
        }
    }
}
