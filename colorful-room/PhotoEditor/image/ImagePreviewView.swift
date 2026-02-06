//
//  ImagePreviewView.swift
//  colorful-room
//
//  Created by macOS on 7/8/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct ImagePreviewView: View {
    var image: UIImage
    var originalImage: UIImage?

    @State private var contentMode: ContentMode = .fit
    @State private var scale: CGFloat = 1.0
    @GestureState private var magnifyBy: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero
    @State private var isShowingOriginal = false

    private var currentScale: CGFloat {
        min(max(scale * magnifyBy, 1.0), 5.0)
    }

    var body: some View {
        GeometryReader { geo in
            let displayImage = (isShowingOriginal && originalImage != nil)
                ? originalImage!
                : image

            ZStack {
                Image(uiImage: displayImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .scaleEffect(currentScale)
                    .offset(
                        x: offset.width + dragOffset.width,
                        y: offset.height + dragOffset.height
                    )
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                    .clipped()
                    .contentShape(Rectangle())
                    .gesture(magnification)
                    .simultaneousGesture(drag)
                    .onTapGesture(count: 2) {
                        withAnimation(.spring(duration: 0.3)) {
                            if scale > 1.0 {
                                // Reset zoom
                                scale = 1.0
                                offset = .zero
                            } else {
                                contentMode = contentMode == .fit ? .fill : .fit
                            }
                        }
                        HapticManager.impact(.light)
                    }

                // Before/after comparison overlay
                if originalImage != nil {
                    VStack {
                        if isShowingOriginal {
                            Text("Original")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial, in: Capsule())
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        Spacer()

                        HStack {
                            CompareButton(isShowingOriginal: $isShowingOriginal)
                            Spacer()
                        }
                    }
                    .padding(12)
                    .animation(.easeInOut(duration: 0.2), value: isShowingOriginal)
                }
            }
        }
        .accessibilityLabel("Photo preview")
        .accessibilityHint("Double-tap to toggle fit and fill. Pinch to zoom. Use compare button to see original.")
    }

    // MARK: - Gestures

    private var magnification: some Gesture {
        MagnifyGesture()
            .updating($magnifyBy) { value, gestureState, _ in
                gestureState = value.magnification
            }
            .onEnded { value in
                let newScale = scale * value.magnification
                if newScale <= 1.0 {
                    withAnimation(.spring(duration: 0.3)) {
                        scale = 1.0
                        offset = .zero
                    }
                } else {
                    scale = min(newScale, 5.0)
                }
            }
    }

    private var drag: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, gestureState, _ in
                if scale * magnifyBy > 1.0 {
                    gestureState = value.translation
                }
            }
            .onEnded { value in
                if scale > 1.0 {
                    offset = CGSize(
                        width: offset.width + value.translation.width,
                        height: offset.height + value.translation.height
                    )
                }
            }
    }
}

// MARK: - Compare Button

struct CompareButton: View {
    @Binding var isShowingOriginal: Bool

    var body: some View {
        Image(systemName: isShowingOriginal ? "eye.fill" : "eye")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.primary)
            .frame(width: 32, height: 32)
            .glassEffect(.regular.interactive(), in: .circle)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isShowingOriginal {
                            isShowingOriginal = true
                            HapticManager.impact(.light)
                        }
                    }
                    .onEnded { _ in
                        isShowingOriginal = false
                    }
            )
            .accessibilityLabel("Compare with original")
            .accessibilityHint("Press and hold to see the original photo")
    }
}

struct ImagePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePreviewView(image: UIImage(named: "carem") ?? UIImage())
    }
}
