//
//  RecipeButton.swift
//  colorful-room
//
//  Created by Ping9 on 09/10/2021.
//  Copyright © 2021 PingAK9. All rights reserved.
//

import SwiftUI
import CoreData

struct RecipeButton: View {
    var data: Recipe
    var on: Bool
    var index: Int
    var onRename: () -> Void

    @Environment(PECtl.self) var shared: PECtl
    @State private var showDeleteConfirmation = false

    private var recipeName: String {
        data.data.recipeName ?? "Recipe \(index)"
    }

    var body: some View {
        Button(action: valueChanged) {
            VStack(spacing: 0) {
                if let preview = data.preview {
                    Image(uiImage: preview)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: DesignTokens.lutThumbnailSize, height: DesignTokens.lutThumbnailSize)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color(uiColor: .tertiarySystemFill))
                        .frame(width: DesignTokens.lutThumbnailSize, height: 60)
                }

                Text(recipeName)
                    .font(.caption)
                    .frame(width: DesignTokens.lutThumbnailSize, height: 24)
                    .foregroundStyle(.primary)
                    .glassEffect(on ? .regular.tint(.accentColor).interactive() : .regular.interactive(), in: .rect(cornerRadius: DesignTokens.cornerRadiusSmall))
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                onRename()
            } label: {
                Label("Rename", systemImage: "pencil")
            }

            Button {
                duplicateItem()
            } label: {
                Label("Duplicate", systemImage: "doc.on.doc")
            }

            Divider()

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .confirmationDialog(
            "Delete \"\(recipeName)\"?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteItem()
            }
        } message: {
            Text("This recipe will be permanently deleted.")
        }
        .accessibilityLabel("\(recipeName) recipe")
        .accessibilityHint(on ? "Currently applied. Long press for options." : "Tap to apply this recipe. Long press for options.")
        .accessibilityAddTraits(on ? .isSelected : [])
    }

    func valueChanged() {
        HapticManager.selection()
        shared.didReceive(action: PECtlAction.applyRecipe(shared.recipesCtrl.recipes[index].data))
    }

    func deleteItem() {
        HapticManager.notification(.warning)
        shared.recipesCtrl.deleteRecipe(index)
    }

    func duplicateItem() {
        HapticManager.impact(.medium)
        shared.recipesCtrl.duplicateRecipe(index)
    }
}


struct RecipeEmptyButton: View {
    var name: String
    var on: Bool
    var action: () -> Void
    
    var body: some View {
        return Button(action: action){
            VStack(spacing: 0){
                Rectangle()
                    .fill(Color(uiColor: .tertiarySystemFill))
                    .frame(width: DesignTokens.lutThumbnailSize, height: DesignTokens.lutThumbnailSize)

                Text(name)
                    .font(.caption)
                    .frame(width: DesignTokens.lutThumbnailSize, height: 24)
                    .foregroundStyle(.primary)
                    .glassEffect(on ? .regular.tint(.accentColor).interactive() : .regular.interactive(), in: .rect(cornerRadius: DesignTokens.cornerRadiusSmall))
            }
        }
        .buttonStyle(.plain)
    }
}
