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
    
    @Environment(PECtl.self) var shared: PECtl
    
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
                    .frame(width: DesignTokens.lutThumbnailSize, height: DesignTokens.lutThumbnailSize)
                    .clipped()
                Text(cube.filter.name)
                    .font(.caption)
                    .frame(width: DesignTokens.lutThumbnailSize, height: 24)
                    .foregroundStyle(.primary)
                    .glassEffect(on ? .regular.tint(.accentColor).interactive() : .regular.interactive(), in: .rect(cornerRadius: DesignTokens.cornerRadiusSmall))
            }
            .frame(width: DesignTokens.lutThumbnailSize)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(cube.filter.name) filter")
        .accessibilityHint(on ? "Tap to adjust intensity" : "Tap to apply this LUT filter")
        .accessibilityAddTraits(on ? .isSelected : [])
    }
    
    func valueChanged() {
        HapticManager.selection()
        shared.lutsCtrl.currentCube = cube.filter.identifier
        shared.didReceive(action: PECtlAction.applyFilter({ $0.colorCube = self.cube.filter }))
    }
    func editAmong(){
        HapticManager.impact(.light)
        self.shared.lutsCtrl.onSetEditingMode(true)
    }
}

struct NeutralButton: View {
    
    var image: UIImage
    @Environment(PECtl.self) var shared: PECtl
    
    var body: some View {
        let on = shared.lutsCtrl.currentCube.isEmpty
        
        return Button(action:valueChanged){
            VStack(spacing: 0){
                Image(uiImage: image)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: DesignTokens.lutThumbnailSize, height: DesignTokens.lutThumbnailSize)
                    .clipped()

                Text("Original")
                    .font(.caption)
                    .frame(width: DesignTokens.lutThumbnailSize, height: 24)
                    .foregroundStyle(.primary)
                    .glassEffect(on ? .regular.tint(.accentColor).interactive() : .regular.interactive(), in: .rect(cornerRadius: DesignTokens.cornerRadiusSmall))
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Original")
        .accessibilityHint("Removes all LUT filters and shows the original image")
        .accessibilityAddTraits(on ? .isSelected : [])
    }
    
    func valueChanged() {
        HapticManager.selection()
        shared.lutsCtrl.selectCube("")
        shared.didReceive(action: PECtlAction.applyFilter({ $0.colorCube = nil }))
    }
}


struct LutLoadingButton: View {
    
    var name:String
    var on:Bool
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(uiColor: .tertiarySystemFill))
                .frame(width: DesignTokens.lutThumbnailSize, height: DesignTokens.lutThumbnailSize)
                .opacity(isAnimating ? 0.4 : 0.8)
                .animation(
                    .easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
                .onAppear {
                    isAnimating = true
                }

            Text(name)
                .font(.caption)
                .frame(width: DesignTokens.lutThumbnailSize, height: 24)
                .foregroundStyle(.primary)
                .glassEffect(on ? .regular.tint(.accentColor).interactive() : .regular.interactive(), in: .rect(cornerRadius: DesignTokens.cornerRadiusSmall))
                .redacted(reason: .placeholder)
        }
        .accessibilityLabel("Loading \(name)")
    }

}
