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
    var data:Recipe
    var on:Bool
    var index:Int
    
    
    @Environment(PECtl.self) var shared: PECtl
    
    var body: some View {
        return Button(action: valueChanged){
            ZStack{
                VStack(spacing: 0){
                    if(data.preview == nil){
                    Rectangle()
                        .fill(Color(uiColor: .tertiarySystemFill))
                        .frame(width: 68, height: 60)
                    }else{
                    Image(uiImage: data.preview!)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 68, height: 68)
                        .clipped()
                    }
                    
                    Text(data.data.recipeName ?? "Recipe \(index)")
                        .font(.caption)
                        .frame(width: 68, height: 24)
                        .foregroundStyle(.primary)
                        .glassEffect(on ? .regular.tint(.accentColor).interactive() : .regular.interactive(), in: .rect(cornerRadius: 8))
                }
                Button(action: deleteItem){
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                }
                .buttonStyle(.glass)
                .frame(width: 60, height: 76, alignment: .topTrailing)
            }
        }
    }
    func valueChanged() {
        shared.didReceive(action: PECtlAction.applyRecipe(shared.recipesCtrl.recipes[index].data))
    }
    func deleteItem() {
        shared.recipesCtrl.deleteRecipe(index)
    }
}


struct RecipeEmptyButton: View {
    var name:String
    var on:Bool
    var action: () -> Void
    
    var body: some View {
        return Button(action: action){
            VStack(spacing: 0){
                Rectangle()
                    .fill(Color(uiColor: .tertiarySystemFill))
                    .frame(width: 68, height: 68)
                
                Text(name)
                    .font(.caption)
                    .frame(width: 68, height: 24)
                    .foregroundStyle(.primary)
                    .glassEffect(on ? .regular.tint(.accentColor).interactive() : .regular.interactive(), in: .rect(cornerRadius: 8))
            }
        }
        .buttonStyle(.plain)
    }
}
