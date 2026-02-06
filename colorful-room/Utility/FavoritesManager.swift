//
//  FavoritesManager.swift
//  colorful-room
//
//  Manages favorite LUT identifiers, persisted via UserDefaults.
//

import Foundation
import os

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "colorful-room", category: "FavoritesManager")

@MainActor
@Observable
class FavoritesManager {

    static let shared = FavoritesManager()

    // MARK: - Keys
    private enum Keys {
        static let favorites = "favoriteLUTIdentifiers"
    }

    // MARK: - State
    var favoriteIdentifiers: Set<String> {
        didSet { saveFavorites() }
    }

    // MARK: - Init

    private init() {
        let savedFavorites = UserDefaults.standard.stringArray(forKey: Keys.favorites) ?? []
        self.favoriteIdentifiers = Set(savedFavorites)
    }

    // MARK: - Favorites

    func isFavorite(_ identifier: String) -> Bool {
        favoriteIdentifiers.contains(identifier)
    }

    func toggleFavorite(_ identifier: String) {
        if favoriteIdentifiers.contains(identifier) {
            favoriteIdentifiers.remove(identifier)
        } else {
            favoriteIdentifiers.insert(identifier)
        }
    }

    // MARK: - Persistence

    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteIdentifiers), forKey: Keys.favorites)
    }
}
