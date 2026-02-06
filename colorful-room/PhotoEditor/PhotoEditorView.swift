//
//  PhotoEditorView.swift
//  colorful-room
//
//  Created by macOS on 7/8/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct PhotoEditorView: View {
    
    @Environment(PECtl.self) var shared: PECtl
    
    var body: some View {
        ZStack{
            VStack(spacing: 0){
                if let image = shared.previewImage {
                    ImagePreviewView(image: image, originalImage: shared.originalPreview)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                } else if shared.originUI != nil {
                    // Loading state: origin loaded but preview not yet rendered
                    ZStack {
                        Rectangle()
                            .fill(Color(uiColor: .tertiarySystemFill))
                        VStack(spacing: 12) {
                            ProgressView()
                                .controlSize(.regular)
                            Text("Processing…")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityLabel("Processing photo")
                } else {
                    // Empty state: no photo selected yet
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 40))
                            .foregroundStyle(.tertiary)
                        Text("Select a photo to edit")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityLabel("No photo loaded")
                }
                EditMenuView()
                    .frame(height: DesignTokens.editMenuHeight)
            }
        }
    }
}
