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
    
    
    @EnvironmentObject var shared:PECtl
    
    var body: some View {
        return Button(action: valueChanged){
            ZStack{
                VStack(spacing: 0){
                    if(data.preview == nil){
                    Rectangle()
                        .fill(Color.myGrayDark)
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
                        .font(.system(size: 11, weight: .medium))
                        .frame(width: 68, height: 24)
                        .background(on ? Color.myPrimary : Color.myButtonDark)
                        .foregroundColor(.white)
                }
                Button(action: deleteItem){
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }.frame(width: 60, height: 76, alignment: .topTrailing)
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
                    .fill(Color.myGrayDark)
                    .frame(width: 68, height: 60)
                
                Text(name)
                    .font(.system(size: 11, weight: .medium))
                    .frame(width: 68, height: 24)
                    .background(on ? Color.myPrimary : Color.myButtonDark)
                    .foregroundColor(.white)
            }
        }
    }
}
