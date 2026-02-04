//
//  LUTButton.swift
//  colorful-room
//
//  Created by macOS on 7/14/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI
import PixelEnginePackage

struct LUTButton: View {
    
    var cube:PreviewFilterColorCube
    
    @EnvironmentObject var shared:PECtl
    
    var body: some View {
        let on = shared.lutsCtrl.currentCube == cube.filter.identifier
        
        return Button(action:{
            if(on){
                self.editAmong()
            }else{
                self.valueChanged()
            }
        }){
            VStack(spacing: 0){
                Image(uiImage: UIImage(cgImage: cube.cgImage))
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 68, height: 68)
                    .clipped()
                Text(cube.filter.name)
                    .font(.system(size: 11, weight: .medium))
                    .frame(width: 68, height: 24)
                    .background(on ? Color.myPrimary : Color.myButtonDark)
                    .foregroundColor(.white)
                
            }
            .frame(width: 68)
        }
    }
    
    func valueChanged() {
        shared.lutsCtrl.currentCube = cube.filter.identifier
        shared.didReceive(action: PECtlAction.applyFilter({ $0.colorCube = self.cube.filter }))
    }
    func editAmong(){
        self.shared.lutsCtrl.onSetEditingMode(true)
    }
}

struct NeutralButton: View {
    
    var image: UIImage
    @EnvironmentObject var shared:PECtl
    
    var body: some View {
        let on = shared.lutsCtrl.currentCube.isEmpty
        
        return Button(action:valueChanged){
            VStack(spacing: 0){
                Image(uiImage: image)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 68, height: 68)
                    .clipped()
                
                Text("Original")
                    .font(.system(size: 11, weight: .medium))
                    .frame(width: 68, height: 24)
                    .background(on ? Color.myPrimary : Color.myButtonDark)
                    .foregroundColor(.white)
            }
        }
    }
    
    func valueChanged() {
        shared.lutsCtrl.selectCube("")
        shared.didReceive(action: PECtlAction.applyFilter({ $0.colorCube = nil }))
    }
}


struct LutLoadingButton: View {
    
    var name:String
    var on:Bool
    
    var body: some View {
        return VStack(spacing: 0){
            Rectangle()
                .fill(Color.myGrayDark)
                .frame(width: 68, height: 68)
            
            Text(name)
                .font(.system(size: 11, weight: .medium))
                .frame(width: 68, height: 24)
                .background(on ? Color.myPrimary : Color.myButtonDark)
                .foregroundColor(.white)
        }
    }
    
    
}
