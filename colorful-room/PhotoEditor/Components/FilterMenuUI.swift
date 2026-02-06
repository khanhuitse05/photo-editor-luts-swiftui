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
                .disabled(shared.currentFilter.edit != .none)
                .opacity(shared.currentFilter.edit != .none ? 0.4 : 1)
                Spacer()
                Text("Edit Color")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
            }
            if shared.currentFilter.edit != .none {
                VStack {
                    Spacer()
                    switch index {
                    case .color:
                        ColorControl()
                    case .contrast:
                        ContrastControl()
                    case .vignette:
                        VignetteControl()
                    case .fade:
                        FadeControl()
                    case .highlights:
                        HighlightsControl()
                    case .hls:
                        HLSControl()
                    case .exposure:
                        ExposureControl()
                    case .saturation:
                        SaturationControl()
                    case .shadows:
                        ShadowsControl()
                    case .sharpen:
                        SharpenControl()
                    case .temperature:
                        TemperatureControl()
                    case .tone:
                        ToneControl()
                    case .white_balance:
                        WhiteBalanceControl()
                    case .gaussianBlur:
                        GaussianBlurControl()
                    case .clarity:
                        ClarityControl()
                    case .none:
                        EmptyView()
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
                        .accessibilityLabel("Cancel")
                        .accessibilityHint("Reverts the current filter change")
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
                        .accessibilityLabel("Apply")
                        .accessibilityHint("Applies the current filter change")
                    }.padding(.bottom, 8)
                }
                .padding(.horizontal)
                .glassCard(cornerRadius: 20)
            }
            
        }
    }
}
