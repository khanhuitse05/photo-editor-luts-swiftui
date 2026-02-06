//
//  RecentEditsView.swift
//  colorful-room
//
//  Displays recent photo edit sessions as a grid of thumbnails with timestamps.
//

import SwiftUI

struct RecentEditsView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var recentManager = RecentEditsManager.shared
    @State private var showClearConfirmation = false
    
    var onSelect: (RecentEditEntry) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea(.all)
                
                if recentManager.entries.isEmpty {
                    emptyStateView
                } else {
                    gridView
                }
            }
            .navigationTitle("Recent Edits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    if !recentManager.entries.isEmpty {
                        Button("Clear All") {
                            showClearConfirmation = true
                        }
                    }
                }
            }
            .confirmationDialog(
                "Clear All Recent Edits?",
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All", role: .destructive) {
                    recentManager.deleteAll()
                }
            } message: {
                Text("This will permanently delete all recent edit sessions.")
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("No Recent Edits")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("Your recent editing sessions will appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Grid View
    
    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 120), spacing: 16)
            ], spacing: 16) {
                ForEach(recentManager.entries) { entry in
                    RecentEditItemView(entry: entry) {
                        onSelect(entry)
                        dismiss()
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - RecentEditItemView

struct RecentEditItemView: View {
    let entry: RecentEditEntry
    let onTap: () -> Void
    
    @State private var thumbnail: UIImage?
    @State private var showDeleteConfirmation = false
    
    private var recentManager: RecentEditsManager {
        RecentEditsManager.shared
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Thumbnail
                Group {
                    if let thumbnail = thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle()
                            .fill(Color(uiColor: .tertiarySystemFill))
                    }
                }
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadiusMedium))
                .overlay {
                    RoundedRectangle(cornerRadius: DesignTokens.cornerRadiusMedium)
                        .stroke(Color(uiColor: .separator), lineWidth: 0.5)
                }
                
                // Timestamp
                Text(relativeTimestamp(for: entry.date))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .confirmationDialog(
            "Delete This Edit?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                recentManager.deleteEntry(entry)
            }
        } message: {
            Text("This edit session will be permanently deleted.")
        }
        .task {
            thumbnail = recentManager.loadThumbnail(for: entry)
        }
        .accessibilityLabel("Edit from \(relativeTimestamp(for: entry.date))")
        .accessibilityHint("Tap to continue editing this photo")
    }
    
    private func relativeTimestamp(for date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "Just now"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes) \(minutes == 1 ? "minute" : "minutes") ago"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours) \(hours == 1 ? "hour" : "hours") ago"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days) \(days == 1 ? "day" : "days") ago"
        }
    }
}

// MARK: - Preview

struct RecentEditsView_Previews: PreviewProvider {
    static var previews: some View {
        RecentEditsView { entry in
            print("Selected entry: \(entry.id)")
        }
    }
}
