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
        
        let all:Bool = shared.currentCollection.isEmpty
        return ZStack{
            VStack{
                Spacer()
                ScrollView(.horizontal, showsIndicators: false){
                    if(shared.loadingLut || shared.cubeSourceCG == nil){
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
                    }else{
                        HStack(spacing: 12){
                            Spacer().frame(width: 0)
                            if(all){
                                NeutralButton(image: UIImage(cgImage: shared.cubeSourceCG!))
                            }
                            
                            if(all){
                                ForEach(shared.collections, id: \.identifier) { collection in
                                    HStack(spacing: 12){
                                        if(collection.cubePreviews.isEmpty == false){
                                            Rectangle()
                                                .fill(Color.myDivider)
                                                .frame(width: 1, height: 92)
                                        }
                                        ForEach(collection.cubePreviews, id: \.filter.identifier) { cube in
                                            LUTButton(cube: cube)
                                        }
                                    }
                                }
                            }else{
                                HStack(spacing: 12){
                                    //Rectangle().fill(Color.myDivider).frame(width: 1, height: 92)
                                    ForEach(shared.currentCubes, id: \.filter.identifier) { cube in
                                        LUTButton(cube: cube)
                                    }
                                }
                            }
                            
                            Spacer().frame(width: 0)
                        }
                    }
                }
                Spacer()
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 16){
                        Spacer().frame(width: 0)
                        CollectionButton(name: "All Luts", key: "")
                        
                        ForEach(shared.collections, id: \.identifier) { collection in
                            CollectionButton(name: collection.name, key: collection.identifier)
                        }
                        
                        Spacer().frame(width: 0)
                    }
                }.padding(.bottom, 8)
            }
            if(self.shared.editingLut){
                VStack{
                    Spacer()
                    ColorCubeControl()
                        .padding()
                    Spacer()
                    HStack{
                        Button(action: {
                            self.shared.editingLut = false
                            self.shared.didReceive(action: PECtl.Action.revert)
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
                            self.shared.editingLut = false
                            self.shared.didReceive(action: PECtl.Action.commit)
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
    }
    
    func scrollToSelectedItem(animated: Bool) {}
}
