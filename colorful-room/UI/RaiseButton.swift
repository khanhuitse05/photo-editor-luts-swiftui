//
//  RaiseButton.swift
//  colorful-room
//
//  Created by macOS on 7/23/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct RaiseButton: View {
    
    var title:String
    var systemName:String
    init(_ title:String, systemName:String = "arrow.down.to.line") {
        self.title = title
        self.systemName = systemName
    }
    
    var body: some View {
        HStack{
            Image(systemName: systemName)
            Text(title)
            
        }
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .frame(minWidth: 160, minHeight: 48)
        .background(Color.myDivider)
        .cornerRadius(40)
    }
}

struct RaiseButton_Previews: PreviewProvider {
    static var previews: some View {
        RaiseButton("Save LUTs image")
    }
}
