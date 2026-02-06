//
//  BatchEditView.swift
//  colorful-room
//
//  Allows users to apply the current edit settings (or clipboard) to
//  multiple photos at once. Uses PhotosPicker for multi-selection.
//

import SwiftUI
import PhotosUI
import PixelEnginePackage
import os

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "colorful-room", category: "BatchEdit")

@MainActor
@Observable
class BatchEditController {

    enum State: Equatable {
        case idle
        case processing(current: Int, total: Int)
        case complete(succeeded: Int, failed: Int)
        case error(String)
    }

    var state: State = .idle
    var processedImages: [UIImage] = []

    /// Applies the given filters to all provided images.
    func processImages(_ images: [UIImage], filters: EditingStack.Edit.Filters) {
        let total = images.count
        state = .processing(current: 0, total: total)
        processedImages = []

        Task.detached(priority: .userInitiated) {
            var succeeded = 0
            let failed = 0

            for (index, uiImage) in images.enumerated() {
                autoreleasepool {
                    let ciImage = convertUItoCI(from: uiImage)
                    let stack = EditingStack(source: StaticImageSource(source: ciImage))
                    stack.set(filters: { $0 = filters })
                    stack.commit()

                    let rendered = stack.makeRenderer().render(resolution: .full)
                    Task { @MainActor in
                        self.processedImages.append(rendered)
                    }
                    succeeded += 1
                }

                await MainActor.run {
                    self.state = .processing(current: index + 1, total: total)
                }
            }

            await MainActor.run {
                self.state = .complete(succeeded: succeeded, failed: failed)
            }
        }
    }

    /// Saves all processed images to the photo library.
    func saveAll(completion: @escaping (Int, Int) -> Void) {
        let images = processedImages
        var saved = 0
        var errors = 0
        let group = DispatchGroup()

        for image in images {
            group.enter()
            let saver = ImageSaver()
            saver.successHandler = {
                saved += 1
                group.leave()
            }
            saver.errorHandler = { _ in
                errors += 1
                group.leave()
            }
            saver.writeToPhotoAlbum(image: image)
        }

        group.notify(queue: .main) {
            completion(saved, errors)
        }
    }

    func reset() {
        state = .idle
        processedImages = []
    }
}

// MARK: - View

struct BatchEditView: View {

    @Environment(PECtl.self) var shared: PECtl
    @Environment(\.dismiss) var dismiss

    @State private var controller = BatchEditController()
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var loadedImages: [UIImage] = []
    @State private var isLoadingPhotos = false
    @State private var showSaveAlert = false
    @State private var saveMessage = ""

    /// The filters to apply (from the current editing session or clipboard).
    private var filtersToApply: EditingStack.Edit.Filters? {
        shared.editState?.currentEdit.filters
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                headerSection
                contentSection
                Spacer()
                actionSection
            }
            .padding()
            .navigationTitle("Batch Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        controller.reset()
                        dismiss()
                    }
                }
            }
            .alert("Batch Save", isPresented: $showSaveAlert) {
                Button("OK") {
                    controller.reset()
                    dismiss()
                }
            } message: {
                Text(saveMessage)
            }
        }
        .onChange(of: selectedItems) { _, newItems in
            loadSelectedPhotos(from: newItems)
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var headerSection: some View {
        if filtersToApply != nil {
            VStack(spacing: 8) {
                Image(systemName: "sparkles.rectangle.stack")
                    .font(.largeTitle)
                    .foregroundStyle(Color.accentColor)
                Text("Apply your current edits to multiple photos at once.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)
        } else {
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(.orange)
                Text("No edits to apply. Edit a photo first or copy edits to the clipboard.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var contentSection: some View {
        switch controller.state {
        case .idle:
            if loadedImages.isEmpty {
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 20,
                    matching: .images
                ) {
                    Label("Select Photos", systemImage: "photo.on.rectangle.angled")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .disabled(filtersToApply == nil)
                .accessibilityLabel("Select photos for batch editing")

                if isLoadingPhotos {
                    ProgressView("Loading photos…")
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(loadedImages.count) photo(s) selected")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(loadedImages.enumerated()), id: \.offset) { _, image in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }

                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 20,
                    matching: .images
                ) {
                    Label("Change Selection", systemImage: "arrow.triangle.2.circlepath")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
            }

        case .processing(let current, let total):
            VStack(spacing: 12) {
                ProgressView(value: Double(current), total: Double(total)) {
                    Text("Processing \(current) of \(total)…")
                        .font(.subheadline)
                }
                .progressViewStyle(.linear)
                .padding(.horizontal)
            }

        case .complete(let succeeded, let failed):
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.green)

                Text("Processing Complete")
                    .font(.headline)

                if failed > 0 {
                    Text("\(succeeded) succeeded, \(failed) failed")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("All \(succeeded) photos processed successfully.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

        case .error(let message):
            VStack(spacing: 8) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.red)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Actions

    @ViewBuilder
    private var actionSection: some View {
        switch controller.state {
        case .idle:
            if !loadedImages.isEmpty && filtersToApply != nil {
                Button {
                    HapticManager.impact(.medium)
                    controller.processImages(loadedImages, filters: filtersToApply!)
                } label: {
                    Label("Apply Edits to All", systemImage: "sparkles")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Apply edits to all selected photos")
            }

        case .processing:
            EmptyView()

        case .complete:
            Button {
                HapticManager.impact(.medium)
                controller.saveAll { saved, errors in
                    if errors > 0 {
                        saveMessage = "\(saved) photos saved, \(errors) failed."
                    } else {
                        saveMessage = "All \(saved) photos saved to your library."
                    }
                    showSaveAlert = true
                    HapticManager.notification(.success)
                }
            } label: {
                Label("Save All to Library", systemImage: "square.and.arrow.down")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel("Save all processed photos to photo library")

        case .error:
            Button("Try Again") {
                controller.reset()
            }
            .buttonStyle(.bordered)
        }
    }

    // MARK: - Helpers

    private func loadSelectedPhotos(from items: [PhotosPickerItem]) {
        isLoadingPhotos = true
        loadedImages = []

        Task {
            var images: [UIImage] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Foundation.Data.self),
                   let uiImage = UIImage(data: data) {
                    images.append(uiImage)
                }
            }
            loadedImages = images
            isLoadingPhotos = false
        }
    }
}
