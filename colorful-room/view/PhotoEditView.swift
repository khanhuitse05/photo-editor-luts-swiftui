//
//  PhotoEditView.swift
//  colorful-room
//
//  Created by macOS on 7/8/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI


struct PhotoEditView: View {
    private let initialImage: UIImage?
    
    @State private var didLoadInitialImage = false
    @State private var showImagePicker = false
    @State private var pickImage: UIImage?
    @Environment(PECtl.self) var shared: PECtl
    @Environment(\.dismiss) var dismiss
    
    init(image initImage: UIImage?) {
        print("Photo edit: init")
        self.initialImage = initImage
    }
    
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color.myBackground
                    .ignoresSafeArea(.all)
                VStack{
                    HStack{
                        Button(action:{
                            self.showImagePicker = true
                        }){
                            Text("Library")
                                .foregroundStyle(.white)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }
                        Spacer()
                        if(shared.previewImage != nil){
                            NavigationLink(destination: ExportView()){
                                Text("Export")
                                    .foregroundStyle(.white)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                            }
                        }
                    }
                    .zIndex(1)
                    PhotoEditorView().frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(0)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showImagePicker, onDismiss: self.loadImage){
            ZStack{
                ImagePicker(image: self.$pickImage)
            }   
        }
        .task {
            guard !didLoadInitialImage else { return }
            didLoadInitialImage = true
            guard let image = initialImage else { return }
            do {
                try await Task.sleep(nanoseconds: 300_000_000) // 300ms
            } catch {
                print("PhotoEditView initial sleep error: \(error)")
            }
            shared.setImage(image: image)
        }
    }
    
    
    func loadImage(){
        print("Photo edit: pick image finish")
        guard let image = self.pickImage else {
            return
        }
        self.pickImage = nil
        print("Photo edit: pick then setImage")
        self.shared.setImage(image: image)
    }
}




struct PhotoEditView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            PhotoEditView(image: UIImage(named: "carem"))
                .background(Color(UIColor.systemBackground))
                .environment(\.colorScheme, .dark)
                .environment(PECtl.shared)
        }
    }
}
