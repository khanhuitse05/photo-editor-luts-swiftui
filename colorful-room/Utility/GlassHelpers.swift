//
//  GlassHelpers.swift
//  colorful-room
//
//  Liquid Glass view modifiers and helpers for consistent usage across the app.
//

import SwiftUI

extension View {
    /// Applies a regular glass effect in a rounded rectangle, for non-interactive surfaces.
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
        self
            .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
    }

    /// Applies a regular interactive glass effect for tappable elements.
    func glassInteractive(cornerRadius: CGFloat = 16) -> some View {
        self
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
    }
}
