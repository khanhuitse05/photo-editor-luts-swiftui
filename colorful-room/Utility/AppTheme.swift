//
//  AppTheme.swift
//  colorful-room
//
//  Created by macOS on 7/15/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//
//  Theme: Uses semantic colors (.primary, .secondary, .background, .tertiary) for native look.
//  Brand accent: Color.myAccent for Liquid Glass tinting and highlights.
//

import SwiftUI

extension Color {
    /// Brand accent color for Liquid Glass tinting and highlights.
    static var myAccent: Color {
        Color("accent")
    }
}
