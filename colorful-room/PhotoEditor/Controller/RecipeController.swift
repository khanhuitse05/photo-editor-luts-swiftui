//
//  RecipeController.swift
//  colorful-room
//
//  Created by Ping9 on 28/06/2022.
//

import Foundation
import Combine
import SwiftUI
import PixelEnginePackage
import CoreData

class RecipeController : ObservableObject{
    
    // Recipe
    @Published var recipes: [Recipe] = []
    
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
        DispatchQueue.global(qos: .background).async{
            print("init Recipe")
            
            for e in self.recipes {
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
