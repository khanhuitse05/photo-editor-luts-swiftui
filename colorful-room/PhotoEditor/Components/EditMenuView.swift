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

                        Spacer()

                        Button {
                            currentView = .lut
                        } label: {
                            IconButton(currentView == .lut ? "edit-lut-highlight" : "edit-lut")
                        }
                        .buttonStyle(.glass)

                        Spacer()

                        Button {
                            if !shared.lutsCtrl.loadingLut {
                                currentView = .filter
                                shared.didReceive(action: PECtlAction.commit)
                            }
                        } label: {
                            IconButton(currentView == .filter ? "edit-color-highlight" : "edit-color")
                        }
                        .buttonStyle(.glass)

                        Spacer()

                        Button {
                            currentView = .recipe
                        } label: {
                            IconButton(currentView == .recipe ? "edit-recipe-highlight" : "edit-recipe")
                        }
                        .buttonStyle(.glass)

                        Spacer()

                        Button {
                            shared.didReceive(action: PECtlAction.undo)
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 20))
                        }
                        .buttonStyle(.glass)
                    }
                    .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
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
