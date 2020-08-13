//
//  PhotoEditorView.swift
//  colorful-room
//
//  Created by macOS on 7/8/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct PhotoEditorView: View {
    
    @EnvironmentObject  var controller:PECtl
    
    var body: some View {
        
        VStack(spacing: 0){
            if(controller.image != nil){
                ImagePreviewView(image: controller.image!)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            }else{
                Rectangle()
                    .fill(Color.myGrayDark)
            }
            EditMenuView()
                .frame(height: 250)
        }
        
    }
}
