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
        self.initialImage = initImage
    }


    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea(.all)
                VStack {
                    HStack {
                        Button(action: {
                            self.showImagePicker = true
                        }) {
                            Label("Library", systemImage: "photo.on.rectangle.angled")
                                .font(.subheadline)
                        }
                        .buttonStyle(.glass)
                        .accessibilityLabel("Photo Library")
                        .accessibilityHint("Opens photo library to pick a different image")
                        Spacer()
                        if shared.previewImage != nil {
                            NavigationLink(destination: ExportView()) {
                                Label("Export", systemImage: "square.and.arrow.up")
                                    .font(.subheadline)
                            }
                            .buttonStyle(.glass)
                            .accessibilityLabel("Export")
                            .accessibilityHint("Opens the export screen to save your edited photo")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .zIndex(1)
                    PhotoEditorView().frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(0)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showImagePicker, onDismiss: self.loadImage) {
            ZStack {
                ImagePicker(image: self.$pickImage)
            }
        }
        .task {
            guard !didLoadInitialImage else { return }
            didLoadInitialImage = true
            guard let image = initialImage else { return }
            do {
                try await Task.sleep(nanoseconds: DesignTokens.initialLoadDelayNanoseconds)
            } catch {
                // Task cancelled — proceed immediately
            }
            shared.setImage(image: image)
        }
    }


    func loadImage() {
        guard let image = self.pickImage else {
            return
        }
        self.pickImage = nil
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
