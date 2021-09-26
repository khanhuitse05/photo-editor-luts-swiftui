//
//  ImageBorder.swift
//  colorful-room
//
//  Created by macOS on 7/23/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct ImageBorder: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaledToFit()
            .border(Color.white, width: 1)
    }
}
