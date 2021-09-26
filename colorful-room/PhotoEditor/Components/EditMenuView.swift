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
                    && self.shared.editingLut == false){
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
                            if(self.shared.loadingLut == false){
                                self.currentView = .filter
                                self.shared.didReceive(action: PECtl.Action.commit)
                            }
                        }){
                            IconButton(self.currentView == .filter ? "edit-color-highlight" : "edit-color")
                        }
                        Button(action:{
                            self.shared.didReceive(action: PECtl.Action.undo)
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
                }
                Spacer()
            }
           
        }
    }
    
    
}

public enum EditView{
    case lut
    case filter
}
