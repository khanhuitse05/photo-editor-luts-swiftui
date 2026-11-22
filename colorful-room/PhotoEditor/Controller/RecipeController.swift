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
    
    var sourceImage: CIImage?
    private var previewTask: Task<Void, Never>?
    
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
    
    func setImage(image: CIImage) {
        previewTask?.cancel()
        self.sourceImage = image
        let recipesSnapshot = self.recipes
        for e in recipesSnapshot {
            e.preview = nil
        }
        previewTask = Task { @MainActor in
            for e in recipesSnapshot {
                guard !Task.isCancelled else { return }
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
         guard index >= 0, index < recipes.count else { return }
         let target = recipes[index].data
         let result = RecipeUtils.deleteRecipe(target)
         if(result){
             if controller.currentRecipe?.objectID == target.objectID {
                 controller.currentRecipe = nil
             }
             recipes.remove(at: index)
         }
     }

     /// Renames the recipe at the given index.
     func renameRecipe(_ index: Int, to newName: String) {
         guard index >= 0, index < recipes.count else { return }
         _ = RecipeUtils.renameRecipe(recipes[index].data, to: newName)
     }

     /// Duplicates the recipe at the given index.
     func duplicateRecipe(_ index: Int) {
         guard index >= 0, index < recipes.count else { return }
         let recipe = recipes[index]
         let newName = (recipe.data.recipeName ?? "Recipe") + " Copy"
         if let newRecipeObject = RecipeUtils.duplicateRecipe(recipe.data, name: newName) {
             let item = Recipe(data: newRecipeObject)
             if let sourceImage = sourceImage {
                 item.setImage(image: sourceImage)
             }
             recipes.append(item)
         }
     }
    
}
