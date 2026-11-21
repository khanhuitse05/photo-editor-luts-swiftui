//
//  ImageSaver.swift
//  test
//
//  Created by macOS on 7/2/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import UIKit
import Photos
import os

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "colorful-room", category: "ImageSaver")

@MainActor
class ImageSaver: NSObject {

    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?

    /// Retains self while an asynchronous PhotoKit or UIKit save operation is in flight
    /// so callers (including fire-and-forget call sites) do not deallocate the saver prematurely.
    private var inFlightRetention: ImageSaver?

    func writeToPhotoAlbum(image: UIImage) {
        withAddOnlyAuthorization { [weak self] in
            self?.performSave(image: image)
        }
    }

    private func performSave(image: UIImage) {
        inFlightRetention = self
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc private nonisolated func saveCompleted(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer?
    ) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            if let error {
                logger.error("Save failed: \(error.localizedDescription)")
                self.complete(with: error)
            } else {
                logger.info("Photo saved successfully.")
                self.completeSuccess()
            }
        }
    }

    /// Saves raw image data (JPEG/PNG/HEIC) to the photo library via PHPhotoLibrary.
    func writeDataToPhotoAlbum(imageData: Foundation.Data) {
        withAddOnlyAuthorization { [weak self] in
            self?.performDataSave(imageData: imageData)
        }
    }

    private func withAddOnlyAuthorization(perform action: @escaping @MainActor () -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .authorized, .limited:
            action()
        case .notDetermined:
            inFlightRetention = self
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] newStatus in
                Task { @MainActor in
                    guard let self else { return }
                    if newStatus == .authorized || newStatus == .limited {
                        action()
                    } else {
                        logger.warning("Photo library permission denied.")
                        self.complete(with: ImageSaverError.permissionDenied)
                    }
                }
            }
        case .denied, .restricted:
            logger.warning("Photo library permission denied or restricted.")
            complete(with: ImageSaverError.permissionDenied)
        @unknown default:
            complete(with: ImageSaverError.permissionDenied)
        }
    }

    private func performDataSave(imageData: Foundation.Data) {
        inFlightRetention = self
        Self.savePhotoDataToLibrary(imageData) { [weak self] success, error in
            Task { @MainActor in
                guard let self else { return }
                if let error {
                    logger.error("Save failed: \(error.localizedDescription)")
                    self.complete(with: error)
                } else if !success {
                    logger.error("Save failed without an error.")
                    self.complete(with: ImageSaverError.saveFailed)
                } else {
                    logger.info("Photo saved successfully.")
                    self.completeSuccess()
                }
            }
        }
    }

    /// Runs PhotoKit's change block outside `@MainActor` isolation because `PHPhotoLibrary`
    /// invokes it on an internal background queue; in Swift 6 a `@MainActor`-isolated
    /// change block crashes with an executor assertion failure at runtime.
    private nonisolated static func savePhotoDataToLibrary(
        _ imageData: Foundation.Data,
        completion: @escaping @Sendable (Bool, Error?) -> Void
    ) {
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: imageData, options: nil)
        }, completionHandler: completion)
    }

    private func completeSuccess() {
        let handler = successHandler
        clearCallbacksAndRetention()
        handler?()
    }

    private func complete(with error: Error) {
        let handler = errorHandler
        clearCallbacksAndRetention()
        handler?(error)
    }

    private func clearCallbacksAndRetention() {
        successHandler = nil
        errorHandler = nil
        inFlightRetention = nil
    }
}

enum ImageSaverError: LocalizedError, Sendable {
    case permissionDenied
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Photo library access is required to save images. Please enable it in Settings."
        case .saveFailed:
            return "Unable to save the image to your photo library."
        }
    }
}
