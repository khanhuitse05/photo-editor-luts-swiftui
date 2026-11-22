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
    var isSelected: Bool = false

    var body: some View {
        Text(name)
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .regular)
            .foregroundStyle(isSelected ? .primary : .secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .contentShape(Capsule())
            .glassEffect(
                isSelected ? .regular.tint(.accentColor).interactive() : .clear,
                in: .capsule
            )
            .accessibilityLabel("\(name) collection")
            .accessibilityHint("Scrolls to the \(name) LUT filters")
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
