//
//  RecipeMenuUI.swift
//  colorful-room
//
//  Created by Ping9 on 09/10/2021.
//  Copyright © 2021 PingAK9. All rights reserved.
//

import SwiftUI
import PixelEnginePackage

struct RecipeMenuUI: View {

    @Environment(PECtl.self) var shared: PECtl

    @State var showInputName: Bool = false
    @State private var renameTarget: Int? = nil

    private var showRenameAlert: Binding<Bool> {
        Binding(
            get: { renameTarget != nil },
            set: { if !$0 { renameTarget = nil } }
        )
    }

    private var renameCurrentName: String {
        guard let idx = renameTarget,
              idx >= 0,
              idx < shared.recipesCtrl.recipes.count else { return "" }
        return shared.recipesCtrl.recipes[idx].data.recipeName ?? "Recipe"
    }

    var body: some View {
        let hasEdit = shared.hasRecipeToSave
        return ZStack {
            VStack {
                Spacer()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Spacer().frame(width: 0)
                        if hasEdit {
                            RecipeEmptyButton(name: "New", on: true, action: {
                                showInputName = true
                            })
                            .accessibilityLabel("Save new recipe")
                            .accessibilityHint("Opens a dialog to name and save the current edit as a recipe")

                            Rectangle()
                                .fill(Color(uiColor: .separator))
                                .frame(width: 1, height: DesignTokens.lutButtonHeight)
                                .accessibilityHidden(true)
                        }
                        ForEach(Array(shared.recipesCtrl.recipes.enumerated()), id: \.offset) { index, item in
                            RecipeButton(
                                data: item,
                                on: item.data.objectID == shared.currentRecipe?.objectID,
                                index: index,
                                onRename: { renameTarget = index }
                            )
                        }

                        Spacer().frame(width: 0)
                    }

                }
                Spacer()
            }

        }
        .alert(isPresented: $showInputName,
                    TextAlert(title: "Enter your Recipe name",
                                  message: "",
                              keyboardType: .default) { result in
                      if let text = result {
                          shared.recipesCtrl.addRecipe(text)
                      }
                    })
        .alert(isPresented: showRenameAlert,
               TextAlert(title: "Rename Recipe",
                         message: "Enter a new name",
                         placeholder: renameCurrentName,
                         keyboardType: .default) { result in
                   if let text = result, !text.isEmpty, let idx = renameTarget {
                       shared.recipesCtrl.renameRecipe(idx, to: text)
                   }
               })
    }
}
