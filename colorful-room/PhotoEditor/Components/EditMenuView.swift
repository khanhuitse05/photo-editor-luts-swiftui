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
    
    @EnvironmentObject var shared:PECtl
    
    @State var currentView:EditView = .lut
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                if((self.currentView == .filter && self.shared.currentEditMenu != .none) == false
                   && self.shared.lutsCtrl.editingLut == false){
                    HStack(spacing: 48){
                        NavigationLink(destination:
                                        CustomCropperView()
                                        .navigationBarTitle("")
                                        .navigationBarHidden(true)
                        ){
                            IconButton("adjustment")
                        }
                        Button(action:{
                            self.currentView = .lut
                        }){
                            IconButton(self.currentView == .lut ? "edit-lut-highlight" : "edit-lut")
                        }
                        Button(action:{
                            if(self.shared.lutsCtrl.loadingLut == false){
                                self.currentView = .filter
                                self.shared.didReceive(action: PECtlAction.commit)
                            }
                        }){
                            IconButton(self.currentView == .filter ? "edit-color-highlight" : "edit-color")
                        }
                        Button(action:{
                            self.currentView = .recipe
                        }){
                            IconButton(self.currentView == .recipe ? "edit-recipe-highlight" : "edit-recipe")
                        }
                        Button(action:{
                            self.shared.didReceive(action: PECtlAction.undo)
                        }){
                            IconButton("icon-undo")
                        }
                    }
                    .frame(width: geometry.size.width, height: 50)
                    .background(Color.myPanel)
                }
                Spacer()
                ZStack{
                    if(self.currentView == .filter){
                        FilterMenuUI()
                    }
                    if(self.currentView == .lut){
                        LutMenuUI()
                    }
                    if(self.currentView == .recipe){
                        RecipeMenuUI()
                    }
                }
                Spacer()
            }
           
        }
    }
    
    
}

public enum EditView{
    case lut
    case filter
    case recipe
}
