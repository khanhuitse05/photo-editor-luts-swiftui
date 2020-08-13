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
    
    @EnvironmentObject var shared:PECtl
    
    var body: some View {
        Button(action: {
            self.shared.currentFilter = self.action
        }){
            VStack(spacing: 4){
                IconButton(self.action.image, size: 36)
                Text(self.action.name)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(Color.myGrayLight)
                    .padding(.top)
            }
            .frame(minWidth: 75)
        }
    }
}
