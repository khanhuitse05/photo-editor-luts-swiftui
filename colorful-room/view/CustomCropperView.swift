//
//  CropperViewController.swift
//  colorful-room
//
//  Created by Ping9 on 26/11/2020.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import Foundation
import SwiftUI
import QCropper


struct CustomCropperView: UIViewControllerRepresentable {
    
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var shared:PECtl
    
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomCropperView>) -> CropperViewController {
        let picker = CropperViewController(originalImage: shared.originUI ?? UIImage(), initialState: shared.cropperCtrl.state)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CropperViewController, context: UIViewControllerRepresentableContext<CustomCropperView>) {
        
    }
    
    func makeCoordinator() -> CropperViewCoordinator {
        CropperViewCoordinator(self)
    }
}

class CropperViewCoordinator: NSObject, UINavigationControllerDelegate, CropperViewControllerDelegate{
    
    let parent: CustomCropperView
    
    init(_ parent:CustomCropperView) {
        self.parent = parent
    }
    
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        PECtl.shared.cropperCtrl.setState(state)
        parent.presentationMode.wrappedValue.dismiss()
    }
    
    func cropperDidCancel(_ cropper: CropperViewController) {
        parent.presentationMode.wrappedValue.dismiss()
    }
}
