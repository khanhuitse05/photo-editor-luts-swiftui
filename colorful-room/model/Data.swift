//
//  EditController.swift
//  test
//
//  Created by macOS on 7/2/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import Foundation
import SwiftUI
import PixelEnginePackage
import os

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "colorful-room", category: "Data")

@Observable
class Data {

    static var shared = Data()

    init() {
        autoreleasepool {
            guard let lutImage = UIImage(named: "lut-normal") else {
                logger.error("Missing asset: lut-normal. Neutral LUT will be unavailable.")
                return
            }
            neutralLUT = lutImage
            neutralCube = FilterColorCube(
                name: "Neutral",
                identifier: "neutral",
                lutImage: neutralLUT,
                dimension: 64
            )

            // basic
            let basic = Collection(name: "Basic", identifier: "Basic", cubeInfos: [])
            for i in 1...10 {
                let cube = FilterColorCubeInfo(
                    name: "A\(i)",
                    identifier: "basic-\(i)",
                    lutImage: "lut-\(i)"
                )
                basic.cubeInfos.append(cube)
            }
            // Cinematic
            let cinematic = Collection(name: "Cinematic", identifier: "Cinematic", cubeInfos: [])
            for i in 1...10 {
                let cube = FilterColorCubeInfo(
                    name: "C\(i)",
                    identifier: "Cinematic-\(i)",
                    lutImage: "cinematic-\(i)"
                )
                cinematic.cubeInfos.append(cube)
            }
            // Film
            let film = Collection(name: "Film", identifier: "Film", cubeInfos: [])
            for i in 1...3 {
                let cube = FilterColorCubeInfo(
                    name: "Film\(i)",
                    identifier: "Film-\(i)",
                    lutImage: "film-\(i)"
                )
                film.cubeInfos.append(cube)
            }
            // Selfie Good Skin
            let selfie = Collection(name: "Selfie", identifier: "Selfie", cubeInfos: [])
            for i in 1...12 {
                let cube = FilterColorCubeInfo(
                    name: "Selfie\(i)",
                    identifier: "Selfie-\(i)",
                    lutImage: "selfie-\(i)"
                )
                selfie.cubeInfos.append(cube)
            }
            // init collections
            self.collections = [basic, cinematic, film, selfie]

            // Build identifier lookup for O(1) cube access
            rebuildCubeLookup()
        }
    }

    var neutralLUT: UIImage!

    var neutralCube: FilterColorCube!
    var collections: [Collection]!

    /// Fast O(1) lookup of cube info by identifier.
    private var cubeLookup: [String: FilterColorCubeInfo] = [:]

    /// Rebuild the identifier-to-cube-info dictionary from current collections.
    private func rebuildCubeLookup() {
        var lookup: [String: FilterColorCubeInfo] = [:]
        for collection in (collections ?? []) {
            for cube in collection.cubeInfos {
                lookup[cube.identifier] = cube
            }
        }
        cubeLookup = lookup
    }

    /// Look up a cube by identifier in O(1) time.
    func cubeBy(identifier: String) -> FilterColorCube? {
        guard !identifier.isEmpty,
              let info = cubeLookup[identifier] else {
            return nil
        }
        return info.getFilter()
    }
}
