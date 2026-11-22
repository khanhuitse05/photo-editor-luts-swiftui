//
//  LutMenuUI.swift
//  colorful-room
//
//  Created by macOS on 7/14/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI
import PixelEnginePackage

struct LutMenuUI: View {
    
    @Environment(PECtl.self) var shared: PECtl
    
    @State private var selectedCategory: String = ""
    @State private var scrollRequest: ScrollRequest? = nil
    @State private var isProgrammaticScroll: Bool = false
    @State private var programmaticScrollTask: Task<Void, Never>? = nil
    @State private var sectionMinX: [String: CGFloat] = [:]
    @State private var isScrolledToEnd: Bool = false

    private struct ScrollRequest: Equatable {
        let targetID: String
        let nonce: Int
    }

    private var favManager: FavoritesManager { FavoritesManager.shared }
    
    /// Gather all cube previews from all collections that match the given identifiers.
    private var favoriteCubes: [PreviewFilterColorCube] {
        let allPreviews = shared.lutsCtrl.collections.flatMap { $0.cubePreviews }
        let lookup = Dictionary(allPreviews.map { ($0.filter.identifier, $0) }, uniquingKeysWith: { first, _ in first })
        return Array(favManager.favoriteIdentifiers).compactMap { lookup[$0] }
    }

    private var visibleCategoryKeys: [String] {
        var keys: [String] = [""]
        if !favoriteCubes.isEmpty {
            keys.append("favorites")
        }
        for collection in shared.lutsCtrl.collections where !collection.cubePreviews.isEmpty {
            keys.append(collection.identifier)
        }
        return keys
    }
    
    var body: some View {
        ZStack{
            VStack{
                Spacer()

                ScrollViewReader { lutReader in
                    ScrollView(.horizontal, showsIndicators: false) {
                        if shared.lutsCtrl.showLoading || shared.lutsCtrl.cubeSourceCG == nil {
                            // Still preparing the neutral cube image or collections – show placeholders.
                            LutMenuUILoading()
                        } else if let cubeSourceCG = shared.lutsCtrl.cubeSourceCG {
                            HStack(spacing: 12) {
                                Spacer().frame(width: 0)
                                // neutral
                                NeutralButton(image: UIImage(cgImage: cubeSourceCG))
                                    .id("neutral")
                                    .onGeometryChange(for: CGFloat.self) { proxy in
                                        proxy.frame(in: .named("lutScroll")).minX
                                    } action: { minX in
                                        updateSectionMinX(key: "", minX: minX)
                                    }

                                // Favorites section
                                if !favoriteCubes.isEmpty {
                                    HStack(spacing: 12) {
                                        lutDivider
                                        ForEach(favoriteCubes, id: \.filter.identifier) { cube in
                                            LUTButton(cube: cube)
                                        }
                                    }
                                    .id("favorites")
                                    .onGeometryChange(for: CGFloat.self) { proxy in
                                        proxy.frame(in: .named("lutScroll")).minX
                                    } action: { minX in
                                        updateSectionMinX(key: "favorites", minX: minX)
                                    }
                                }

                                // cube by collections
                                ForEach(shared.lutsCtrl.collections, id: \.identifier) { collection in
                                    if !collection.cubePreviews.isEmpty {
                                        HStack(spacing: 12) {
                                            lutDivider
                                            ForEach(collection.cubePreviews, id: \.filter.identifier) { cube in
                                                LUTButton(cube: cube)
                                            }
                                        }
                                        .onGeometryChange(for: CGFloat.self) { proxy in
                                            proxy.frame(in: .named("lutScroll")).minX
                                        } action: { minX in
                                            updateSectionMinX(key: collection.identifier, minX: minX)
                                        }
                                    }
                                }
                                Spacer().frame(width: 0)
                            }
                        }
                    }
                    .coordinateSpace(name: "lutScroll")
                    .onScrollPhaseChange { _, newPhase in
                        if newPhase == .interacting || newPhase == .decelerating {
                            programmaticScrollTask?.cancel()
                            isProgrammaticScroll = false
                        } else if newPhase == .idle && isProgrammaticScroll {
                            programmaticScrollTask?.cancel()
                            isProgrammaticScroll = false
                        }
                    }
                    .onScrollGeometryChange(for: Bool.self) { geo in
                        let maxOffset = max(0, geo.contentSize.width - geo.containerSize.width)
                        return maxOffset > 0 && geo.contentOffset.x >= maxOffset - 4
                    } action: { _, atEnd in
                        isScrolledToEnd = atEnd
                        if !isProgrammaticScroll {
                            recomputeSelectedCategory()
                        }
                    }
                    .onChange(of: scrollRequest) { _, request in
                        guard let request else { return }
                        withAnimation {
                            lutReader.scrollTo(request.targetID, anchor: .leading)
                        }
                    }
                }
                Spacer()
                ScrollViewReader { categoryReader in
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack(spacing: 8){
                            Spacer().frame(width: 4)
                        
                            collectionButtonView(key: "", name: "All Luts")

                            if !favoriteCubes.isEmpty {
                                collectionButtonView(key: "favorites", name: "Favorites")
                            }
                            //
                            ForEach(shared.lutsCtrl.collections, id: \.identifier) { collection in
                                collectionButtonView(key: collection.identifier, name: collection.name)
                            }
                            Spacer().frame(width: 4)
                        }
                    }
                    .onChange(of: selectedCategory) { _, newCategory in
                        withAnimation {
                            categoryReader.scrollTo(newCategory, anchor: .center)
                        }
                    }
                }
                .padding(.bottom, 8)
            }
            if(self.shared.lutsCtrl.editingLut){
                LutMenuUIEdit()
            }
        }
    }

    private var lutDivider: some View {
        Rectangle()
            .fill(Color(uiColor: .separator))
            .frame(width: 1, height: DesignTokens.lutButtonHeight)
            .accessibilityHidden(true)
    }

    private func updateSectionMinX(key: String, minX: CGFloat) {
        sectionMinX[key] = minX
        if !isProgrammaticScroll {
            recomputeSelectedCategory()
        }
    }

    private func recomputeSelectedCategory() {
        let keys = visibleCategoryKeys
        guard !keys.isEmpty else { return }

        if isScrolledToEnd, let lastKey = keys.last {
            if selectedCategory != lastKey {
                selectedCategory = lastKey
            }
            return
        }

        // Highlight the rightmost section whose leading edge has entered near the viewport leading edge.
        let threshold: CGFloat = 44
        var active = ""
        for key in keys where !key.isEmpty {
            if let minX = sectionMinX[key], minX <= threshold {
                active = key
            }
        }
        if selectedCategory != active {
            selectedCategory = active
        }
    }
    
    @ViewBuilder
    func collectionButtonView(key: String, name: String) -> some View {
        Button(action:{
            HapticManager.selection()
            programmaticScrollTask?.cancel()
            isProgrammaticScroll = true
            selectedCategory = key
            let targetID = key.isEmpty ? "neutral" : key
            scrollRequest = ScrollRequest(targetID: targetID, nonce: (scrollRequest?.nonce ?? 0) + 1)
            programmaticScrollTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 600_000_000)
                if !Task.isCancelled {
                    isProgrammaticScroll = false
                }
            }
        }){
            CollectionButton(name: name, isSelected: selectedCategory == key)
        }
        .buttonStyle(.plain)
        .id(key)
    }
}


///
struct LutMenuUILoading: View{
    var body: some View{
        HStack(spacing: 12){
            Spacer().frame(width: 0)
            LutLoadingButton(name: "Original", on: true)
            Rectangle()
                .fill(Color(uiColor: .separator))
                .frame(width: 1, height: DesignTokens.lutButtonHeight)
                .accessibilityHidden(true)
            LutLoadingButton(name: "LUT 1", on: false)
            LutLoadingButton(name: "LUT 2", on: false)
            LutLoadingButton(name: "LUT 3", on: false)
            Spacer().frame(width: 0)
        }
    }
}

///
struct LutMenuUIEdit: View{
    
    @Environment(PECtl.self) var shared: PECtl
    
    var body: some View{
        VStack{
            Spacer()
            ColorCubeControl()
                .padding()
            Spacer()
            HStack{
                Button(action: {
                    self.shared.didReceive(action: PECtlAction.revert)
                    self.shared.lutsCtrl.onSetEditingMode(false)
                }){
                    Image(systemName: "xmark")
                }
                .buttonStyle(.glass)
                .accessibilityLabel("Cancel")
                .accessibilityHint("Reverts the LUT intensity change")
                Spacer()
                Text(self.shared.editState.currentEdit.filters.colorCube?.name ?? "Lut")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(action: {
                    self.shared.didReceive(action: PECtlAction.commit)
                    self.shared.lutsCtrl.onSetEditingMode(false)
                }){
                    Image(systemName: "checkmark")
                }
                .buttonStyle(.glass)
                .accessibilityLabel("Apply")
                .accessibilityHint("Applies the LUT intensity change")
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .glassCard(cornerRadius: 20)
    }
}
