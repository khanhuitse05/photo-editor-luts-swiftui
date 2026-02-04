//
//  LutMenuUI.swift
//  colorful-room
//
//  Created by macOS on 7/14/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct LutMenuUI: View {
    
    @EnvironmentObject var shared:PECtl
    
    var body: some View {
        ZStack{
            ScrollViewReader{ reader in
                VStack{
                    Spacer()
                    
                    ScrollView(.horizontal, showsIndicators: false){
                        if(shared.lutsCtrl.showLoading){
                            LutMenuUILoading()
                        }else{
                            HStack(spacing: 12){
                                Spacer().frame(width: 0)
                                // neutral
                                NeutralButton(image: UIImage(cgImage: shared.lutsCtrl.cubeSourceCG!)).id("neutral")
                                // cube by collections
                                ForEach(shared.lutsCtrl.collections, id: \.identifier) { collection in
                                    HStack(spacing: 12){
                                        if(collection.cubePreviews.isEmpty == false){
                                            Rectangle()
                                                .fill(Color.myDivider)
                                                .frame(width: 1, height: 92)
                                        }
                                        ForEach(collection.cubePreviews, id: \.filter.identifier) { cube in
                                            LUTButton(cube: cube)
                                        }
                                    }.id("\(collection.identifier)-cube")
                                }
                                Spacer().frame(width: 0)
                            }
                        }
                    }
                    Spacer()
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack(spacing: 16){
                            Spacer().frame(width: 0)
                        
                            collectionButtonView(key: "", name: "All Luts", reader:reader)
                            //
                            ForEach(shared.lutsCtrl.collections, id: \.identifier) { collection in
                                collectionButtonView(key: collection.identifier, name: collection.name,reader:reader)
                            }
                            Spacer().frame(width: 0)
                        }
                    }.padding(.bottom, 8)
                }
                
            } // ScrollViewReader
            if(self.shared.lutsCtrl.editingLut){
                LutMenuUIEdit()
            }
        }
    }
    
    @ViewBuilder
    func collectionButtonView(key:String, name: String, reader:ScrollViewProxy) -> some View {
        Button(action:{
            withAnimation{
                if(key.isEmpty){
                    reader.scrollTo("neutral")
                }else{
                    reader.scrollTo("\(key)-cube", anchor: .leading)
                }
            }
        }){
            CollectionButton(name: name)
        }
    }
}


///
struct LutMenuUILoading: View{
    var body: some View{
        HStack(spacing: 12){
            Spacer().frame(width: 0)
            LutLoadingButton(name: "Original", on: true)
            Rectangle()
                .fill(Color.myDivider)
                .frame(width: 1, height: 92)
            LutLoadingButton(name: "LUT 1", on: false)
            LutLoadingButton(name: "LUT 2", on: false)
            LutLoadingButton(name: "LUT 3", on: false)
            Spacer().frame(width: 0)
        }
    }
}

///
struct LutMenuUIEdit: View{
    
    @EnvironmentObject var shared:PECtl
    
    var body: some View{
        VStack{
            Spacer()
            ColorCubeControl()
                .padding()
            Spacer()
            HStack{
                Button(action: {
                    self.shared.didReceive(action: PECtlAction.revert)
                    self.shared.lutsCtrl.onSetEditingMode(false)
                }){
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
                Spacer()
                Text(self.shared.editState.currentEdit.filters.colorCube?.name ?? "Lut")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.myGrayLight)
                Spacer()
                Button(action: {
                    self.shared.didReceive(action: PECtlAction.commit)
                    self.shared.lutsCtrl.onSetEditingMode(false)
                }){
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color.myBackground)
    }
}
