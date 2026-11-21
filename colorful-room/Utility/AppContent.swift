//
//  AppContent.swift
//  colorful-room
//
//  Created by Ping9 on 26/11/2020.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import Foundation

struct IntroItem: Identifiable {
    let id = UUID()
    let title: String
    let subTitle: String
    let leadingImage: String
    let highlight: String?
}

struct RoadMapItem: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let date: String
    let isHighlighted: Bool
}

enum AppContent {

    static let introContent: [IntroItem] = [
        IntroItem(
            title: "One-Tap LUT Filters",
            subTitle: "Cinematic, film and selfie looks, all free",
            leadingImage: "edit-lut",
            highlight: nil
        ),
        IntroItem(
            title: "Selective Color (HSL)",
            subTitle: "Fine-tune each color in your photo",
            leadingImage: "hls",
            highlight: nil
        ),
        IntroItem(
            title: "13 Pro Adjustments",
            subTitle: "Light, color, detail, vignette and more",
            leadingImage: "edit-color",
            highlight: nil
        ),
        IntroItem(
            title: "Recipes & Batch Edit",
            subTitle: "Save your look and apply it to many photos",
            leadingImage: "edit-recipe",
            highlight: nil
        )
    ]

    static let roadMapDescription = "Your great contribution will help our team a lot to continue developing better product."

    static let roadMapContent: [RoadMapItem] = [
        RoadMapItem(
            title: "Launching Production v1.0",
            body: "Basic editor, include HLS editor, export your picture and LUTs image",
            date: "August 15, 2020",
            isHighlighted: false
        ),
        RoadMapItem(
            title: "Launching Production v1.1",
            body: "You can crop image, import more LUTs templates",
            date: "December 1, 2020",
            isHighlighted: true
        ),
        RoadMapItem(
            title: "Add Effect tool & export all effect",
            body: "You can add effect and export all effects image that you can use for AR filter",
            date: "2021",
            isHighlighted: false
        ),
        RoadMapItem(
            title: "Export Spark AR filter",
            body: "You can export Spark AR project file when done editing!",
            date: "2021",
            isHighlighted: false
        )
    ]
}

// MARK: - Backward compatibility alias
typealias K = AppContent
