//
//  CollectionButton.swift
//  colorful-room
//
//  Created by macOS on 7/16/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct CollectionButton: View {
    var name: String
    
    @Environment(PECtl.self) var shared: PECtl
    
    var body: some View {
        Text(name)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}
