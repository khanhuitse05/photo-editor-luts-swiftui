//
//  EditMenuControlView.swift
//  colorful-room
//
//  Created by macOS on 7/8/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI
import QCropper

struct EditMenuView: View {
    
    @Environment(PECtl.self) var shared: PECtl
    
    @State var currentView:EditView = .lut
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if ((currentView == .filter && shared.currentEditMenu != .none) == false
                    && shared.lutsCtrl.editingLut == false) {
                    HStack {
                        NavigationLink(destination: CustomCropperView()
                            .toolbar(.hidden, for: .navigationBar)
                        ) {
                            IconButton("adjustment")
                        }
                        .buttonStyle(.glass)
                        .accessibilityLabel("Crop & Adjust")
                        .accessibilityHint("Opens the crop and adjustment tool")

                        Spacer()

                        Button {
                            HapticManager.selection()
                            currentView = .lut
                        } label: {
                            IconButton(currentView == .lut ? "edit-lut-highlight" : "edit-lut")
                        }
                        .buttonStyle(.glass)
                        .accessibilityLabel("LUT Filters")
                        .accessibilityHint("Shows color lookup table filters")
                        .accessibilityAddTraits(currentView == .lut ? .isSelected : [])

                        Spacer()

                        Button {
                            if !shared.lutsCtrl.loadingLut {
                                HapticManager.selection()
                                currentView = .filter
                                shared.didReceive(action: PECtlAction.commit)
                            }
                        } label: {
                            IconButton(currentView == .filter ? "edit-color-highlight" : "edit-color")
                        }
                        .buttonStyle(.glass)
                        .accessibilityLabel("Edit Color")
                        .accessibilityHint("Shows color editing controls")
                        .accessibilityAddTraits(currentView == .filter ? .isSelected : [])

                        Spacer()

                        Button {
                            HapticManager.selection()
                            currentView = .recipe
                        } label: {
                            IconButton(currentView == .recipe ? "edit-recipe-highlight" : "edit-recipe")
                        }
                        .buttonStyle(.glass)
                        .accessibilityLabel("Recipes")
                        .accessibilityHint("Shows saved editing recipes")
                        .accessibilityAddTraits(currentView == .recipe ? .isSelected : [])

                        Spacer()

                        Button {
                            HapticManager.impact(.medium)
                            shared.didReceive(action: PECtlAction.undo)
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 20))
                        }
                        .buttonStyle(.glass)
                        .disabled(shared.editState?.canUndo != true)
                        .accessibilityLabel("Undo")
                        .accessibilityHint("Undoes the last edit")

                        Button {
                            HapticManager.impact(.medium)
                            shared.didReceive(action: PECtlAction.redo)
                        } label: {
                            Image(systemName: "arrow.uturn.forward")
                                .font(.system(size: 20))
                        }
                        .buttonStyle(.glass)
                        .disabled(!shared.canRedo)
                        .accessibilityLabel("Redo")
                        .accessibilityHint("Redoes the last undone edit")
                    }
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.toolbarHeight, maxHeight: DesignTokens.toolbarHeight)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
                }
                Spacer()
                menuContent
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var menuContent: some View {
        switch currentView {
        case .filter:
            FilterMenuUI()
        case .lut:
            LutMenuUI()
        case .recipe:
            RecipeMenuUI()
        }
    }
    
    
}

public enum EditView{
    case lut
    case filter
    case recipe
}
