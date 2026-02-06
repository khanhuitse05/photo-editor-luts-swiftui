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

class ImageSaver: NSObject {

    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?

    func writeToPhotoAlbum(image: UIImage) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .authorized, .limited:
            performSave(image: image)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self?.performSave(image: image)
                    } else {
                        let error = ImageSaverError.permissionDenied
                        logger.warning("Photo library permission denied.")
                        self?.errorHandler?(error)
                    }
                }
            }
        case .denied, .restricted:
            let error = ImageSaverError.permissionDenied
            logger.warning("Photo library permission denied or restricted.")
            errorHandler?(error)
        @unknown default:
            let error = ImageSaverError.permissionDenied
            errorHandler?(error)
        }
    }

    private func performSave(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            logger.error("Save failed: \(error.localizedDescription)")
            errorHandler?(error)
        } else {
            logger.info("Photo saved successfully.")
            successHandler?()
        }
    }

    /// Saves raw image data (JPEG/PNG/HEIC) to the photo library via PHPhotoLibrary.
    func writeDataToPhotoAlbum(imageData: Foundation.Data) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .authorized, .limited:
            performDataSave(imageData: imageData)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self?.performDataSave(imageData: imageData)
                    } else {
                        let error = ImageSaverError.permissionDenied
                        logger.warning("Photo library permission denied.")
                        self?.errorHandler?(error)
                    }
                }
            }
        case .denied, .restricted:
            let error = ImageSaverError.permissionDenied
            logger.warning("Photo library permission denied or restricted.")
            errorHandler?(error)
        @unknown default:
            let error = ImageSaverError.permissionDenied
            errorHandler?(error)
        }
    }

    private func performDataSave(imageData: Foundation.Data) {
        PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: imageData, options: nil)
        } completionHandler: { [weak self] success, error in
            DispatchQueue.main.async {
                if let error = error {
                    logger.error("Save failed: \(error.localizedDescription)")
                    self?.errorHandler?(error)
                } else {
                    logger.info("Photo saved successfully.")
                    self?.successHandler?()
                }
            }
        }
    }
}

enum ImageSaverError: LocalizedError {
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Photo library access is required to save images. Please enable it in Settings."
        }
    }
}
