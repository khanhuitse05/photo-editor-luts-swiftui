//
//  Constants.swift
//  colorful-room
//
//  Created by Ping9 on 16/01/2022.
//

import Foundation

public enum Constants {
    static let supportFilters: [FilterModel] = [
        FilterModel("Brightness", edit: .exposure),
        FilterModel("Contrast", edit: .contrast),
        FilterModel("Saturation", edit: .saturation),
        FilterModel("White Balance", image: "temperature", edit: .white_balance),
        FilterModel("Tone", image: "tone", edit: .tone),
        FilterModel("HSL", image: "hls", edit: .hls),
        FilterModel("Fade", edit: .fade),
        FilterModel("Highlights", image: "highlights", edit: .highlights),
        FilterModel("Shadows", image: "shadows", edit: .shadows),
        FilterModel("Sharpen", image: "sharpen", edit: .sharpen),
        FilterModel("Vignette", image: "vignette", edit: .vignette),
        FilterModel("Blur", image: "gaussianblur", edit: .gaussianBlur),
        FilterModel("Clarity", image: "clarity", edit: .clarity),
    ]
}

/// Centralized design tokens to replace magic numbers across the codebase.
public enum DesignTokens {
    // MARK: - Preview & Image Sizes
    static let previewSize: CGFloat = 512
    static let thumbnailScale: CGFloat = 128

    // MARK: - Timing
    static let filterDebounceNanoseconds: UInt64 = 300_000_000 // 0.3s
    static let initialLoadDelayNanoseconds: UInt64 = 300_000_000 // 0.3s

    // MARK: - Corner Radii
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cornerRadiusXLarge: CGFloat = 20

    // MARK: - Component Heights
    static let toolbarHeight: CGFloat = 50
    static let lutButtonHeight: CGFloat = 92
    static let editMenuHeight: CGFloat = 250
    static let exportPreviewHeight: CGFloat = 400

    // MARK: - Button & Icon Sizes
    static let iconSizeSmall: CGFloat = 32
    static let iconSizeMedium: CGFloat = 36
    static let lutThumbnailSize: CGFloat = 68
}
