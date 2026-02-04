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
        Label(title, systemImage: systemName)
            .font(.subheadline)
            .frame(minWidth: 160, minHeight: 48)
    }
}

struct RaiseButton_Previews: PreviewProvider {
    static var previews: some View {
        RaiseButton("Save LUTs image")
    }
}
