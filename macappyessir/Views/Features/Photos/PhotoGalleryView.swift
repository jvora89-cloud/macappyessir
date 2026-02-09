//
//  PhotoGalleryView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/8/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct PhotoGalleryView: View {
    @Environment(AppState.self) private var appState
    let job: Job

    @State private var isImporting = false
    @State private var selectedImageURL: URL? = nil

    var photoURLs: [URL] {
        job.photos.compactMap { URL(fileURLWithPath: $0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header with Add Button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Project Photos")
                        .font(.headline)
                    Text("\(job.photos.count) photos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: { isImporting = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Photos")
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            if photoURLs.isEmpty {
                // Empty State
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text("No Photos Yet")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("Add before and after photos to document your work")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button(action: { isImporting = true }) {
                        HStack {
                            Image(systemName: "photo.badge.plus")
                            Text("Add First Photo")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(12)
            } else {
                // Photo Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 150), spacing: 16)
                    ], spacing: 16) {
                        ForEach(photoURLs, id: \.self) { url in
                            PhotoGridItem(url: url, onDelete: {
                                deletePhoto(url)
                            })
                            .onTapGesture {
                                selectedImageURL = url
                            }
                        }
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.image],
            allowsMultipleSelection: true
        ) { result in
            handleImageImport(result)
        }
        .sheet(item: $selectedImageURL) { url in
            PhotoDetailView(imageURL: url)
        }
    }

    private func handleImageImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            var updatedJob = job
            for url in urls {
                if let savedPath = DataManager.shared.savePhoto(from: url, forJobId: job.id) {
                    updatedJob.photos.append(savedPath)
                }
            }
            appState.updateJob(updatedJob)
            appState.toastManager.show(message: "\(urls.count) photo(s) added!", icon: "photo.fill")

        case .failure(let error):
            print("❌ Photo import failed: \(error)")
            appState.toastManager.show(message: "Failed to import photos", icon: "exclamationmark.triangle")
        }
    }

    private func deletePhoto(_ url: URL) {
        var updatedJob = job
        updatedJob.photos.removeAll { $0 == url.path }
        appState.updateJob(updatedJob)
        DataManager.shared.deletePhoto(at: url.path)
        appState.toastManager.show(message: "Photo deleted", icon: "trash")
    }
}

struct PhotoGridItem: View {
    let url: URL
    let onDelete: () -> Void
    @State private var isHovered = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let nsImage = NSImage(contentsOf: url) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 150)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title)
                            .foregroundColor(.gray)
                    )
            }

            if isHovered {
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                        .background(Circle().fill(Color.white))
                }
                .buttonStyle(.plain)
                .padding(8)
            }
        }
        .onHover { hovering in
            withAnimation {
                isHovered = hovering
            }
        }
    }
}

struct PhotoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let imageURL: URL

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(imageURL.lastPathComponent)
                    .font(.headline)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Image
            if let nsImage = NSImage(contentsOf: imageURL) {
                GeometryReader { geometry in
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }

            Divider()

            // Footer
            HStack {
                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button(action: { openInFinder() }) {
                    HStack {
                        Image(systemName: "folder")
                        Text("Show in Finder")
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 800, height: 600)
    }

    private func openInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([imageURL])
    }
}

// Make URL Identifiable for sheet
extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

#Preview {
    PhotoGalleryView(job: Job(
        clientName: "John Smith",
        address: "123 Main St",
        contractorType: .kitchen,
        description: "Kitchen remodel",
        estimatedCost: 25000
    ))
    .environment(AppState())
}
