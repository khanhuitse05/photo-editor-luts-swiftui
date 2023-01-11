//
//  PhotoEditorView.swift
//  colorful-room
//
//  Created by macOS on 7/8/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct PhotoEditorView: View {
    
    @EnvironmentObject  var shared:PECtl
    
    var body: some View {
        ZStack{
            VStack(spacing: 0){
                if let image = shared.previewImage{
                    ImagePreviewView(image: image)
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
}
