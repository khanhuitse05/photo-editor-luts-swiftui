//
//  ButtonView.swift
//  colorful-room
//
//  Created by macOS on 7/8/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct ButtonView: View {
    
    var action:FilterModel
    
    @Environment(PECtl.self) var shared: PECtl
    
    var body: some View {
        Button(action: {
            self.shared.currentFilter = self.action
        }){
            VStack(spacing: 0){
                IconButton(self.action.image, size: 36)
                Text(self.action.name)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.top)
            }
            .frame(minWidth: 75)
            .padding(8)
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
