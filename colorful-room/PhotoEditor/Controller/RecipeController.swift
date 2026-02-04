//
//  RecipeController.swift
//  colorful-room
//
//  Created by Ping9 on 28/06/2022.
//

import Foundation
import SwiftUI
import PixelEnginePackage
import CoreData

@MainActor
@Observable
class RecipeController {
    
    // Recipe
    var recipes: [Recipe] = []
    
    var sourceImage:CIImage?
    
    var controller: PECtl {
        get {
            PECtl.shared
        }
    }
    
    init(){
        let data = RecipeUtils.loadRecipe()
        self.recipes = []
        for e in data {
            let item = Recipe(data: e)
            recipes.append(item)
        }
    }
    
    func setImage(image:CIImage){
        self.sourceImage = image
        // Work on a snapshot of the recipes array off the main actor to
        // avoid touching main-actor-isolated state from a detached task.
        let recipesSnapshot = self.recipes
        Task.detached(priority: .background) {
            print("init Recipe")
            for e in recipesSnapshot {
                e.setImage(image: image)
            }
        }
    }
    
     ///
     func addRecipe(_ name: String){
         if let e = RecipeUtils.addRecipe(name, filters: controller.editState.currentEdit.filters){
             let item = Recipe(data: e)
             if(sourceImage != nil){
                 item.setImage(image: sourceImage!)
             }
             recipes.append(item)
             controller.currentRecipe = item.data
         }
     }
     
     ///
     func deleteRecipe(_ index:Int){
         let result = RecipeUtils.deleteRecipe(recipes[index].data)
         if(result){
             recipes.remove(at: index)
         }
     }
    
}
