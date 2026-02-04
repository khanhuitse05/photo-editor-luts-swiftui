//
//  ColorSelectButton.swift
//  colorful-room
//
//  Created by macOS on 7/8/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct ColorSelectButton: View {
    
    var index:Int
    @Binding var current:Int
    
    var body: some View {
        
        let color = HLSControl.colors[index]
        return ZStack{
            if(current == index){
                Button(action: action){
                    Circle()
                        .fill(color)
                        .frame(width: 18, height: 18)
                        .padding(.all, 4)
                        .overlay(
                            Circle()
                                .stroke(color, lineWidth: 2)
                    )
                }
            }else{
                Button(action: action){
                    Circle()
                        .fill(color)
                        .frame(width: 24, height: 24)
                }
            }
        }
        
    }
    func action(){
        self.current = self.index
    }
}
