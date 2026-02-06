//
//  Export.swift
//  colorful-room
//
//  Created by Ping9 on 16/01/2022.
//

import Foundation
import SwiftUI
import PixelEnginePackage
import QCropper
import CoreData
import ImageIO
import UniformTypeIdentifiers
import os

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "colorful-room", category: "ExportController")

// MARK: - Export Format & Quality

enum ExportFormat: String, CaseIterable, Identifiable {
    case heic = "HEIC"
    case jpeg = "JPEG"
    case png = "PNG"

    var id: String { rawValue }
}

enum ExportQuality: String, CaseIterable, Identifiable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    var id: String { rawValue }

    var compressionQuality: CGFloat {
        switch self {
        case .high: return 1.0
        case .medium: return 0.7
        case .low: return 0.4
        }
    }
}

// MARK: - Export Controller

@MainActor
@Observable
class ExportController {

    enum ExportState: Equatable {
        case idle
        case exporting
        case success
        case error(String)
    }

    // Export
    var originExport: UIImage?
    var exportState: ExportState = .idle
    var exportFormat: ExportFormat = .jpeg
    var exportQuality: ExportQuality = .high

    var originRatio: Double {
        PECtl.shared.originUI.size.width / PECtl.shared.originUI.size.height
    }

    var controller: PECtl {
        PECtl.shared
    }

    @MainActor
    func prepareExport() {
        guard originExport == nil else { return }

        controller.didReceive(action: .commit)

        if let cropperState = controller.cropperCtrl.state {
            guard let originRender = controller.originUI.cropped(withCropperState: cropperState) else {
                logger.error("Failed to crop image for export.")
                exportState = .error("Failed to prepare image for export.")
                return
            }
            let source = StaticImageSource(source: convertUItoCI(from: originRender))
            self.originExport = controller.editState.makeCustomRenderer(source: source)
                .render(resolution: .full)
        } else {
            self.originExport = controller.editState.makeRenderer().render(resolution: .full)
        }

        if originExport == nil {
            logger.error("Render returned nil during export preparation.")
            exportState = .error("Failed to render the final image.")
        }
    }

    func resetExport() {
        originExport = nil
        exportState = .idle
    }

    func exportOrigin() {
        guard let origin = originExport else {
            exportState = .error("No image available to save.")
            return
        }

        guard let imageData = encodeImage(origin) else {
            exportState = .error("Failed to encode image as \(exportFormat.rawValue).")
            HapticManager.notification(.error)
            return
        }

        exportState = .exporting

        let saver = ImageSaver()
        saver.successHandler = { [weak self] in
            Task { @MainActor in
                self?.exportState = .success
                HapticManager.notification(.success)
            }
        }
        saver.errorHandler = { [weak self] error in
            Task { @MainActor in
                logger.error("Export failed: \(error.localizedDescription)")
                self?.exportState = .error(error.localizedDescription)
                HapticManager.notification(.error)
            }
        }
        saver.writeDataToPhotoAlbum(imageData: imageData)
    }

    // MARK: - Image Encoding

    private func encodeImage(_ image: UIImage) -> Foundation.Data? {
        switch exportFormat {
        case .jpeg:
            return image.jpegData(compressionQuality: exportQuality.compressionQuality)
        case .png:
            return image.pngData()
        case .heic:
            return heicData(for: image, compressionQuality: exportQuality.compressionQuality)
        }
    }

    private func heicData(for image: UIImage, compressionQuality: CGFloat) -> Foundation.Data? {
        guard let cgImage = image.cgImage else { return nil }
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data, UTType.heic.identifier as CFString, 1, nil
        ) else { return nil }
        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]
        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Foundation.Data
    }
}
