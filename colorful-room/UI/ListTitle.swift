//
//  ListTitle.swift
//  colorful-room
//
//  Created by macOS on 7/16/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct ListTitle: View {

    var title: String
    var subTitle: String
    var leadingImage: String
    var highlight: String

    init(title: String?, subTitle: String?, leadingImage: String?, highlight: String? = "") {
        self.title = title ?? ""
        self.subTitle = subTitle ?? ""
        self.leadingImage = leadingImage ?? ""
        self.highlight = highlight ?? ""
    }

    // Keep backward-compatible initializer with old parameter name
    init(title: String?, supTitle: String?, leadingImage: String?, highlight: String? = "") {
        self.init(title: title, subTitle: supTitle, leadingImage: leadingImage, highlight: highlight)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Image(leadingImage)
                .resizable()
                .scaledToFit()
                .frame(width: DesignTokens.iconSizeSmall, height: DesignTokens.iconSizeSmall)
                .padding(.trailing, 20)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                    if highlight.isEmpty == false {
                        Text(highlight)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .glassEffect(.regular, in: .rect(cornerRadius: 6))
                    }
                    Spacer()
                }

                Text(subTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(subTitle)")
    }
}

struct ListTitle_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ListTitle(
                title: "Free and Premium Filters",
                subTitle: "Export your picture, Lookup image, all effects, and more",
                leadingImage: "edit-lut",
                highlight: "AR filter"
            )
                .background(Color(UIColor.systemBackground))
                .environment(\.colorScheme, .dark)
        }
    }
}
