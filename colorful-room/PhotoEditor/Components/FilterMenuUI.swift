//
//  FilterMenuView.swift
//  colorful-room
//
//  Created by macOS on 7/14/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct FilterMenuUI: View {
    
    @Environment(PECtl.self) var shared: PECtl
    var index:EditMenu {
        get {
            return shared.currentEditMenu
        }
    }
    
    
    var body: some View {
        ZStack{
            
            VStack{
                Spacer()
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 8){
                        Spacer().frame(width: 0)
                        ForEach(Constants.supportFilters, id: \.name) { filter in
                            ButtonView(action: filter)
                        }
                        Spacer().frame(width: 0)
                    }
                }
                Spacer()
                Text("Edit Color")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
            }
            if shared.currentFilter.edit != .none {
                VStack (){
                    Spacer()
                    if index == .color {
                        ColorControl()
                    }else if index == .contrast {
                        ContrastControl()
                    }else if index == .vignette {
                        VignetteControl()
                    }else if index == .fade {
                        FadeControl()
                    }else if index == .highlights {
                        HighlightsControl()
                    }else if index == .hls {
                        HLSControl()
                    }else if index == .exposure {
                        ExposureControl()
                    }else if index == .saturation {
                        SaturationControl()
                    }else if index == .shadows {
                        ShadowsControl()
                    }else if index == .sharpen {
                        SharpenControl()
                    }else if index == .temperature {
                        TemperatureControl()
                    }else if index == .vignette {
                        VignetteControl()
                    }else if index == .tone {
                        ToneControl()
                    }else if index == .white_balance {
                        WhiteBalanceControl()
                    }else{
                        Text("Todo")
                    }
                    
                    Spacer()
                    HStack{
                        Button(action: {
                            self.shared.didReceive(action: PECtlAction.revert)
                            self.shared.currentFilter = FilterModel.noneFilterModel
                        }){
                            Image(systemName: "xmark")
                        }
                        .buttonStyle(.glass)
                        Spacer()
                        Text(shared.currentFilter.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button(action: {
                            self.shared.didReceive(action: PECtlAction.commit)
                            self.shared.currentFilter = FilterModel.noneFilterModel
                        }){
                            Image(systemName: "checkmark")
                        }
                        .buttonStyle(.glass)
                    }.padding(.bottom, 8)
                }
                .padding(.horizontal)
                .glassCard(cornerRadius: 20)
            }
            
        }
    }
}
