//
//  HapticManager.swift
//  colorful-room
//
//  Centralized haptic feedback utility for consistent tactile responses across the app.
//

import UIKit

enum HapticManager {

    /// Triggers an impact haptic with the given style.
    /// Use for button taps, filter selection, zoom changes.
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    /// Triggers a notification haptic.
    /// Use `.success` for export completion, `.error` for failures, `.warning` for destructive actions.
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    /// Triggers a selection change haptic.
    /// Use for tab switches, recipe/LUT selection, picker changes.
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
