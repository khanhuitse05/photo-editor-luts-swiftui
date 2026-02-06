//
//  RecentEditsManager.swift
//  colorful-room
//
//  Manages recent photo edit sessions, persisted via UserDefaults (metadata) and FileManager (images).
//

import Foundation
import UIKit
import CoreImage
import PixelEnginePackage
import os

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "colorful-room", category: "RecentEditsManager")

// MARK: - RecentEditEntry

struct RecentEditEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    
    // Filter parameters (mirrors RecipeObject attributes)
    let contrast: Double
    let saturation: Double
    let exposure: Double
    let highlights: Double
    let shadows: Double
    let temperature: Double
    let gaussianBlur: Double
    let vignette: Double
    let fade: Double
    let whiteBalanceTemperature: Double
    let whiteBalanceTint: Double
    let lutIdentifier: String
    let lutAmount: Double
    let colorValueSaturation: Double
    let colorValueBrightness: Double
    let colorValueContrast: Double
    let sharpenSharpness: Double
    let sharpenRadius: Double
    let unsharpMaskIntensity: Double
    let unsharpMaskRadius: Double
    let hls: String
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        contrast: Double = 0.0,
        saturation: Double = 0.0,
        exposure: Double = 0.0,
        highlights: Double = 0.0,
        shadows: Double = 0.0,
        temperature: Double = 0.0,
        gaussianBlur: Double = 0.0,
        vignette: Double = 0.0,
        fade: Double = 0.0,
        whiteBalanceTemperature: Double = 0.0,
        whiteBalanceTint: Double = 0.0,
        lutIdentifier: String = "",
        lutAmount: Double = 1.0,
        colorValueSaturation: Double = 1.0,
        colorValueBrightness: Double = 0.0,
        colorValueContrast: Double = 1.0,
        sharpenSharpness: Double = 0.0,
        sharpenRadius: Double = 0.0,
        unsharpMaskIntensity: Double = 0.0,
        unsharpMaskRadius: Double = 0.0,
        hls: String = ""
    ) {
        self.id = id
        self.date = date
        self.contrast = contrast
        self.saturation = saturation
        self.exposure = exposure
        self.highlights = highlights
        self.shadows = shadows
        self.temperature = temperature
        self.gaussianBlur = gaussianBlur
        self.vignette = vignette
        self.fade = fade
        self.whiteBalanceTemperature = whiteBalanceTemperature
        self.whiteBalanceTint = whiteBalanceTint
        self.lutIdentifier = lutIdentifier
        self.lutAmount = lutAmount
        self.colorValueSaturation = colorValueSaturation
        self.colorValueBrightness = colorValueBrightness
        self.colorValueContrast = colorValueContrast
        self.sharpenSharpness = sharpenSharpness
        self.sharpenRadius = sharpenRadius
        self.unsharpMaskIntensity = unsharpMaskIntensity
        self.unsharpMaskRadius = unsharpMaskRadius
        self.hls = hls
    }
}

// MARK: - RecentEditsManager

@MainActor
@Observable
class RecentEditsManager {
    
    static let shared = RecentEditsManager()
    
    // MARK: - Keys
    
    private enum Keys {
        static let recentEdits = "recentEditEntries"
    }
    
    private static let maxEntries = 5
    private static let thumbnailSize: CGFloat = 200
    
    // MARK: - State
    
    private(set) var entries: [RecentEditEntry] = [] {
        didSet {
            saveMetadata()
        }
    }
    
    var hasRecent: Bool {
        !entries.isEmpty
    }
    
    // MARK: - Init
    
    private init() {
        loadMetadata()
    }
    
    // MARK: - File Paths
    
    private var recentEditsDirectory: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let recentEditsDir = documentsDirectory.appendingPathComponent("RecentEdits")
        
        // Ensure directory exists
        try? FileManager.default.createDirectory(at: recentEditsDir, withIntermediateDirectories: true)
        
        return recentEditsDir
    }
    
    private func imagePath(for entry: RecentEditEntry) -> URL {
        recentEditsDirectory.appendingPathComponent("\(entry.id.uuidString).jpg")
    }
    
    private func thumbnailPath(for entry: RecentEditEntry) -> URL {
        recentEditsDirectory.appendingPathComponent("\(entry.id.uuidString)_thumb.jpg")
    }
    
    // MARK: - Save Edit
    
    func saveEdit(image: UIImage, filters: EditingStack.Edit.Filters) {
        let entry = RecentEditEntry(
            contrast: filters.contrast?.value ?? 0.0,
            saturation: filters.saturation?.value ?? 0.0,
            exposure: filters.exposure?.value ?? 0.0,
            highlights: filters.highlights?.value ?? 0.0,
            shadows: filters.shadows?.value ?? 0.0,
            temperature: filters.temperature?.value ?? 0.0,
            gaussianBlur: filters.gaussianBlur?.value ?? 0.0,
            vignette: filters.vignette?.value ?? 0.0,
            fade: filters.fade?.intensity ?? 0.0,
            whiteBalanceTemperature: filters.whiteBalance?.valueTemperature ?? 0.0,
            whiteBalanceTint: filters.whiteBalance?.valueTint ?? 0.0,
            lutIdentifier: filters.colorCube?.identifier ?? "",
            lutAmount: filters.colorCube?.amount ?? 1.0,
            colorValueSaturation: filters.color?.valueSaturation ?? 1.0,
            colorValueBrightness: filters.color?.valueBrightness ?? 0.0,
            colorValueContrast: filters.color?.valueContrast ?? 1.0,
            sharpenSharpness: filters.sharpen?.sharpness ?? 0.0,
            sharpenRadius: filters.sharpen?.radius ?? 0.0,
            unsharpMaskIntensity: filters.unsharpMask?.intensity ?? 0.0,
            unsharpMaskRadius: filters.unsharpMask?.radius ?? 0.0,
            hls: RecipeUtils.arrayVectorToString(filters.hls?.inputShift)
        )
        
        // Save original image
        if let imageData = image.jpegData(compressionQuality: 0.9) {
            let imageURL = imagePath(for: entry)
            try? imageData.write(to: imageURL)
        }
        
        // Generate and save thumbnail
        if let thumbnail = generateThumbnail(from: image) {
            if let thumbnailData = thumbnail.jpegData(compressionQuality: 0.8) {
                let thumbnailURL = thumbnailPath(for: entry)
                try? thumbnailData.write(to: thumbnailURL)
            }
        }
        
        // Add entry and prune if needed
        entries.insert(entry, at: 0)
        if entries.count > Self.maxEntries {
            let entriesToRemove = entries.suffix(entries.count - Self.maxEntries)
            entries.removeLast(entries.count - Self.maxEntries)
            
            // Delete files for removed entries
            for removedEntry in entriesToRemove {
                deleteFiles(for: removedEntry)
            }
        }
    }
    
    // MARK: - Load Images
    
    func loadImage(for entry: RecentEditEntry) -> UIImage? {
        let imageURL = imagePath(for: entry)
        guard let imageData = try? Foundation.Data(contentsOf: imageURL) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    func loadThumbnail(for entry: RecentEditEntry) -> UIImage? {
        let thumbnailURL = thumbnailPath(for: entry)
        guard let thumbnailData = try? Foundation.Data(contentsOf: thumbnailURL) else {
            return nil
        }
        return UIImage(data: thumbnailData)
    }
    
    // MARK: - Restore Filters
    
    func restoreFilters(from entry: RecentEditEntry) -> (inout EditingStack.Edit.Filters) -> Void {
        let colorCube: FilterColorCube? = Data.shared.cubeBy(identifier: entry.lutIdentifier)
        
        var contrast = FilterContrast()
        contrast.value = entry.contrast
        
        var saturation = FilterSaturation()
        saturation.value = entry.saturation
        
        var exposure = FilterExposure()
        exposure.value = entry.exposure
        
        var highlights = FilterHighlights()
        highlights.value = entry.highlights
        
        var shadows = FilterShadows()
        shadows.value = entry.shadows
        
        var temperature = FilterTemperature()
        temperature.value = entry.temperature
        
        var gaussianBlur = FilterGaussianBlur()
        gaussianBlur.value = entry.gaussianBlur
        
        var vignette = FilterVignette()
        vignette.value = entry.vignette
        
        var fade = FilterFade()
        fade.intensity = entry.fade
        
        var whiteBalance = FilterWhiteBalance()
        whiteBalance.valueTemperature = entry.whiteBalanceTemperature
        whiteBalance.valueTint = entry.whiteBalanceTint
        
        var colorCubeFilter: FilterColorCube? = colorCube
        colorCubeFilter?.amount = entry.lutAmount
        
        var color = FilterColor()
        color.valueSaturation = entry.colorValueSaturation
        color.valueBrightness = entry.colorValueBrightness
        color.valueContrast = entry.colorValueContrast
        
        var sharpen = FilterSharpen()
        sharpen.sharpness = entry.sharpenSharpness
        sharpen.radius = entry.sharpenRadius
        
        var unsharpMask = FilterUnsharpMask()
        unsharpMask.intensity = entry.unsharpMaskIntensity
        unsharpMask.radius = entry.unsharpMaskRadius
        
        var hls = FilterHLS()
        hls.inputShift = RecipeUtils.stringToArrayVector(entry.hls)
        
        return {
            $0.contrast = contrast
            $0.saturation = saturation
            $0.exposure = exposure
            $0.highlights = highlights
            $0.shadows = shadows
            $0.temperature = temperature
            $0.gaussianBlur = gaussianBlur
            $0.vignette = vignette
            $0.fade = fade
            $0.whiteBalance = whiteBalance
            $0.colorCube = colorCubeFilter
            $0.color = color
            $0.sharpen = sharpen
            $0.unsharpMask = unsharpMask
            $0.hls = hls
        }
    }
    
    // MARK: - Delete
    
    func deleteEntry(_ entry: RecentEditEntry) {
        entries.removeAll { $0.id == entry.id }
        deleteFiles(for: entry)
    }
    
    func deleteAll() {
        let allEntries = entries
        entries.removeAll()
        
        for entry in allEntries {
            deleteFiles(for: entry)
        }
        
        // Remove directory if empty
        try? FileManager.default.removeItem(at: recentEditsDirectory)
    }
    
    // MARK: - Private Helpers
    
    private func generateThumbnail(from image: UIImage) -> UIImage? {
        let size = image.size
        let maxDimension = max(size.width, size.height)
        let scale = Self.thumbnailSize / maxDimension
        
        guard let ciImage = CIImage(image: image) else { return nil }
        
        if let resized = resizedImage(at: ciImage, scale: scale, aspectRatio: 1.0),
           let cgImage = sharedContext.createCGImage(resized, from: resized.extent) {
            return UIImage(cgImage: cgImage)
        }
        
        return nil
    }
    
    private func deleteFiles(for entry: RecentEditEntry) {
        let imageURL = imagePath(for: entry)
        let thumbnailURL = thumbnailPath(for: entry)
        
        try? FileManager.default.removeItem(at: imageURL)
        try? FileManager.default.removeItem(at: thumbnailURL)
    }
    
    // MARK: - Persistence
    
    private func saveMetadata() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: Keys.recentEdits)
        }
    }
    
    private func loadMetadata() {
        guard let data = UserDefaults.standard.data(forKey: Keys.recentEdits),
              let decoded = try? JSONDecoder().decode([RecentEditEntry].self, from: data) else {
            entries = []
            return
        }
        
        // Sort by date descending (most recent first)
        entries = decoded.sorted { $0.date > $1.date }
        
        // Prune if somehow we have more than maxEntries
        if entries.count > Self.maxEntries {
            let entriesToRemove = entries.suffix(entries.count - Self.maxEntries)
            entries.removeLast(entries.count - Self.maxEntries)
            
            for removedEntry in entriesToRemove {
                deleteFiles(for: removedEntry)
            }
        }
    }
}
