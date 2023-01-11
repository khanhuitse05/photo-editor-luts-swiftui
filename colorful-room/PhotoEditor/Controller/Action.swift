//
//  Action.swift
//  colorful-room
//
//  Created by Ping9 on 16/01/2022.
//

import Foundation
import PixelEnginePackage
import QCropper

    
public enum PECtlAction {
    case setFilter((inout EditingStack.Edit.Filters) -> Void)
    case applyFilter((inout EditingStack.Edit.Filters) -> Void)
    case commit
    case revert
    case undo
    case applyRecipe(RecipeObject)
}
