//
//  FiltersController.swift
//  colorful-room
//
//  Created by Ping9 on 28/06/2022.
//

import Foundation
import PixelEnginePackage

/// Manages the list of available photo-editing filters and tracks the active filter state.
@MainActor
@Observable
class FiltersController {

    /// The currently selected filter (`.none` when no filter panel is open).
    var currentFilter: FilterModel = FilterModel.noneFilterModel

    /// The filters exposed to the user in the edit menu.
    var supportedFilters: [FilterModel] {
        Constants.supportFilters
    }

    /// Whether a filter control panel is currently active.
    var isEditing: Bool {
        currentFilter.edit != .none
    }

    /// Select a filter to begin editing.
    func selectFilter(_ filter: FilterModel) {
        currentFilter = filter
    }

    /// Clear the active filter selection.
    func clearSelection() {
        currentFilter = FilterModel.noneFilterModel
    }
}
