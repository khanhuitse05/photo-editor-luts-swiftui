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
    
    @EnvironmentObject var shared:PECtl
    
    @State var filterIntensity:Double = 0
    
    @State var showInputName:Bool = false
    
    var body: some View {
        let hasEdit = PECtl.shared.hasRecipeToSave
        return  ZStack{
            VStack{
                Spacer()
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 12){
                        Spacer().frame(width: 0)
                       // todo: current recipe
                        if hasEdit{
                            RecipeEmptyButton(name: "New", on: true, action: {
                                showInputName = true
                            })
                        
                            // todo: saved recipe
                            Rectangle()
                                .fill(Color.myDivider)
                                .frame(width: 1, height: 92)
                        }
                        ForEach(Array(shared.recipesCtrl.recipes.enumerated()), id: \.offset) { index, item in
                            RecipeButton(
                                data: item,
                                on: item.data.objectID == shared.currentRecipe?.objectID,
                                index: index
                            )
                        }
                        
                        Spacer().frame(width: 0)
                    }
                    
                }
                Spacer()
            }
           
        }
        .onAppear(perform: didReceiveCurrentEdit)
        .alert(isPresented: $showInputName,
                    TextAlert(title: "Enter your Recipe name",
                                  message: "",
                              keyboardType: .default) { result in
                      if let text = result {
                        // has Text input
                          shared.recipesCtrl.addRecipe(text)
                      }
                    })
    }
    
    func didReceiveCurrentEdit() {
        
        let edit: EditingStack.Edit = PECtl.shared.editState.currentEdit
        self.filterIntensity = edit.filters.fade?.intensity ?? 0
    }
    
}
