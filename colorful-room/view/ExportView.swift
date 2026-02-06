//
//  ExportView.swift
//  colorful-room
//
//  Created by macOS on 7/23/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct ExportView: View {

    @State var shared: ExportController = ExportController()
    @State private var showShareSheet = false

    @Environment(\.dismiss) var dismiss

    private var showAlert: Binding<Bool> {
        Binding(
            get: { shared.exportState == .success || isErrorState },
            set: { if !$0 { shared.exportState = .idle } }
        )
    }

    private var isErrorState: Bool {
        if case .error = shared.exportState { return true }
        return false
    }

    private var errorMessage: String {
        if case .error(let msg) = shared.exportState { return msg }
        return ""
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea(.all)
            VStack(spacing: 0) {
                // MARK: - Title & Close
                HStack {
                    Spacer().frame(width: 24)
                    Spacer()
                    Text("Export your photo")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Button(action: {
                        self.shared.resetExport()
                        self.dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.glass)
                    .accessibilityLabel("Close")
                    .accessibilityHint("Closes the export screen")
                }
                .padding()
                .padding(.horizontal)
                Text("Download or share your edited photo.\nAlways for FREE")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)

                Spacer()

                // MARK: - Preview
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        Spacer().frame(width: 8)
                        VStack {
                            if let origin = self.shared.originExport {
                                Image(uiImage: origin)
                                    .resizable()
                                    .modifier(ImageBorder())
                                    .accessibilityLabel("Edited photo preview")
                            } else {
                                Rectangle()
                                    .fill(Color(uiColor: .tertiarySystemFill))
                                    .frame(width: self.shared.originRatio * 320)
                                    .accessibilityLabel("Loading photo preview")
                            }
                        }
                        Spacer().frame(width: 8)
                    }
                }
                .frame(height: DesignTokens.exportPreviewHeight)
                .clipped()

                Spacer()

                // MARK: - Action Buttons
                HStack(spacing: 16) {
                    // Share button
                    Button {
                        showShareSheet = true
                        HapticManager.impact(.medium)
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.subheadline)
                    }
                    .frame(minWidth: 120, minHeight: 48)
                    .buttonStyle(.glass)
                    .disabled(shared.originExport == nil)
                    .accessibilityLabel("Share photo")
                    .accessibilityHint("Opens the share sheet to share the edited photo")

                    // Save button
                    Button {
                        self.shared.exportOrigin()
                        HapticManager.impact(.medium)
                    } label: {
                        if shared.exportState == .exporting {
                            ProgressView()
                                .frame(minWidth: 120, minHeight: 48)
                        } else {
                            Label("Save", systemImage: "arrow.down.to.line")
                                .font(.subheadline)
                        }
                    }
                    .frame(minWidth: 120, minHeight: 48)
                    .buttonStyle(.glassProminent)
                    .disabled(shared.exportState == .exporting || shared.originExport == nil)
                    .accessibilityLabel("Save picture")
                    .accessibilityHint("Saves the edited photo to your photo library")
                }
                .padding(.top, 16)

                Spacer().frame(height: 16)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert(isPresented: showAlert) {
            if shared.exportState == .success {
                Alert(
                    title: Text("Success"),
                    message: Text("Photo saved successfully."),
                    dismissButton: .default(Text("Close"))
                )
            } else {
                Alert(
                    title: Text("Export Failed"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = shared.originExport {
                ActivityViewController(activityItems: [image])
            }
        }
        .onAppear {
            shared.prepareExport()
        }
    }
}

// MARK: - Share Sheet

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        let shared = PECtl.shared
        shared.originUI = UIImage(named: "carem")
        return ExportView()
            .background(Color(UIColor.systemBackground))
            .environment(\.colorScheme, .dark)
            .environment(shared)
    }
}
