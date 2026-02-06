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
    private let recentEditEntry: RecentEditEntry?

    @State private var didLoadInitialImage = false
    @State private var showImagePicker = false
    @State private var showBatchEdit = false
    @State private var showHistory = false
    @State private var pickImage: UIImage?
    @Environment(PECtl.self) var shared: PECtl
    @Environment(\.dismiss) var dismiss

    init(image initImage: UIImage?, recentEditEntry: RecentEditEntry? = nil) {
        self.initialImage = initImage
        self.recentEditEntry = recentEditEntry
    }


    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea(.all)
                VStack {
                    HStack(spacing: 12) {
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
                            // History button
                            Button {
                                HapticManager.impact(.light)
                                showHistory = true
                            } label: {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.subheadline)
                            }
                            .buttonStyle(.glass)
                            .accessibilityLabel("History")
                            .accessibilityHint("View recent editing sessions")
                            
                            // Batch edit
                            Button {
                                HapticManager.impact(.light)
                                showBatchEdit = true
                            } label: {
                                Image(systemName: "rectangle.stack.badge.play")
                                    .font(.subheadline)
                            }
                            .buttonStyle(.glass)
                            .accessibilityLabel("Batch Edit")
                            .accessibilityHint("Apply current edits to multiple photos at once")

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
        .sheet(isPresented: $showBatchEdit) {
            BatchEditView()
                .environment(shared)
        }
        .sheet(isPresented: $showHistory) {
            RecentEditsView { entry in
                // Load the image and restore filters
                if let image = RecentEditsManager.shared.loadImage(for: entry) {
                    shared.setImage(image: image)
                    // Wait for setImage to complete, then restore filters
                    Task {
                        // Give setImage time to rebuild the editing stack
                        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
                        let filterClosure = RecentEditsManager.shared.restoreFilters(from: entry)
                        shared.didReceive(action: .applyFilter(filterClosure))
                    }
                }
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
            
            // If we have a recentEditEntry, restore filters after image loads
            if let entry = recentEditEntry {
                // Wait for setImage to complete, then restore filters
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
                let filterClosure = RecentEditsManager.shared.restoreFilters(from: entry)
                shared.didReceive(action: .applyFilter(filterClosure))
            }
        }
        .onDisappear {
            // Auto-save current editing session if edits exist
            if let originUI = shared.originUI,
               let editState = shared.editState,
               editState.canUndo {
                RecentEditsManager.shared.saveEdit(
                    image: originUI,
                    filters: editState.currentEdit.filters
                )
            }
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
