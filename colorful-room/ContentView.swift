//
//  ContentView.swift
//  colorful-room
//
//  Created by macOS on 7/3/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI
import UIKit
import PixelEnginePackage

struct ContentView: View {

    @State private var showSheet = false

    @State private var showImageEdit = false
    // for pick view
    @State private var pickImage: UIImage?
    // for edit view
    @State private var inputImage: UIImage?
    @State private var selectedRecentEntry: RecentEditEntry?


    var body: some View {

        NavigationStack {
            // Scroll only when the intro doesn't fit the window (e.g. short landscape windows on iPhone Duo).
            ViewThatFits(in: .vertical) {
                introContent
                ScrollView {
                    introContent
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                SwiftUI.Image("intro-image")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()
                    .accessibilityHidden(true)
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showImageEdit) {
                PhotoEditView(
                    image: inputImage,
                    recentEditEntry: selectedRecentEntry
                )
            }
        }
        .sheet(isPresented: $showSheet, onDismiss: loadImage) {
            ImagePicker(image: self.$pickImage)
        }

    }

    private var introContent: some View {
        VStack {
            Spacer()

            VStack(alignment: .center, spacing: 24) {
                VStack(spacing: 8) {
                    Text("SNAPTUNE")
                        .font(.caption.weight(.semibold))
                        .tracking(4)
                        .foregroundStyle(.white.opacity(0.7))

                    Text("Tune Every Shot")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.myAccent,
                                    Color(red: 0.55, green: 0.45, blue: 1.0),
                                    Color(red: 1.0, green: 0.45, blue: 0.65)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 4)

                    Text("Pro color grading in one tap")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 2)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.isHeader)
                VStack(spacing: 4) {
                    ForEach(AppContent.introContent) { item in
                        ListTitle(
                            title: item.title,
                            subTitle: item.subTitle,
                            leadingImage: item.leadingImage,
                            highlight: item.highlight ?? ""
                        )
                        .padding(.vertical, 8)
                        .glassCard(cornerRadius: DesignTokens.cornerRadiusMedium)
                        .accessibilityElement(children: .combine)
                    }
                }
                .padding(.horizontal, 16)
                Spacer().frame(height: 0)

                Button {
                    selectedRecentEntry = nil
                    showSheet = true
                    showImageEdit = false
                    inputImage = nil
                } label: {
                    Label("Choose Your Picture", systemImage: "photo.badge.plus")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .glassEffect(.regular.tint(Color.myAccent.opacity(0.6)).interactive(), in: .rect(cornerRadius: DesignTokens.cornerRadiusLarge))
                .overlay {
                    RoundedRectangle(cornerRadius: DesignTokens.cornerRadiusLarge)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: Color.myAccent.opacity(0.2), radius: 12, x: 0, y: 4)
                .padding(.horizontal, 30)
                .accessibilityLabel("Choose Your Picture")
                .accessibilityHint("Opens the photo library to select a picture to edit")

                // Continue Editing button
                if RecentEditsManager.shared.hasRecent {
                    Button {
                        if let mostRecent = RecentEditsManager.shared.entries.first,
                           let continueImage = RecentEditsManager.shared.loadImage(for: mostRecent) {
                            selectedRecentEntry = mostRecent
                            PECtl.shared.setImage(image: continueImage)
                            inputImage = continueImage
                            showImageEdit = true
                        }
                    } label: {
                        Label("Continue Editing", systemImage: "arrow.clockwise")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.white.opacity(0.9))
                    }
                    .padding(.horizontal, 32)
                }

                Spacer().frame(height: 0)
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
        }
    }

    func loadImage() {
        guard let pick = self.pickImage else {
            return
        }
        selectedRecentEntry = nil
        PECtl.shared.setImage(image: pick)
        self.inputImage = pick
        self.showImageEdit = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .background(Color(UIColor.systemBackground))
                .environment(\.colorScheme, .dark)
                .environment(PECtl.shared)
                .environment(Data.shared)
        }
    }
}
