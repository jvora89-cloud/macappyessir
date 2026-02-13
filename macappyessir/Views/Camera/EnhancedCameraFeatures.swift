//
//  EnhancedCameraFeatures.swift
//  macappyessir
//
//  Created by Jay Vora on 2/7/26.
//  Photo review, editing, batch mode, and annotations
//

import SwiftUI
import AppKit

// MARK: - Photo Review & Edit Screen

struct PhotoReviewView: View {
    @Environment(\.dismiss) private var dismiss
    let image: NSImage
    let onSave: (NSImage) -> Void
    let onRetake: () -> Void

    @State private var currentImage: NSImage
    @State private var showEditTools = false
    @State private var brightness: Double = 1.0
    @State private var contrast: Double = 1.0
    @State private var rotation: Double = 0

    init(image: NSImage, onSave: @escaping (NSImage) -> Void, onRetake: @escaping () -> Void) {
        self.image = image
        self.onSave = onSave
        self.onRetake = onRetake
        _currentImage = State(initialValue: image)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Retake") {
                    onRetake()
                    dismiss()
                }
                .buttonStyle(.bordered)

                Spacer()

                Text("Review Photo")
                    .font(.headline)

                Spacer()

                Button(action: {
                    onSave(currentImage)
                    dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Use Photo")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Image preview
            ZStack {
                Color.black

                Image(nsImage: currentImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .rotation3DEffect(
                        .degrees(rotation),
                        axis: (x: 0, y: 0, z: 1)
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            // Edit tools
            VStack(spacing: 16) {
                HStack {
                    Button(action: { showEditTools.toggle() }) {
                        HStack(spacing: 6) {
                            Image(systemName: showEditTools ? "slider.horizontal.3" : "slider.horizontal.3")
                            Text(showEditTools ? "Hide Tools" : "Edit Tools")
                        }
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button(action: resetAdjustments) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(.bordered)
                    .disabled(!hasAdjustments)
                }

                if showEditTools {
                    editToolsPanel
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .frame(minWidth: 700, minHeight: 700)
        .onChange(of: brightness) { _, _ in applyFilters() }
        .onChange(of: contrast) { _, _ in applyFilters() }
        .onChange(of: rotation) { _, _ in applyRotation() }
    }

    private var editToolsPanel: some View {
        VStack(spacing: 12) {
            // Brightness
            HStack {
                Image(systemName: "sun.max.fill")
                    .frame(width: 30)
                Slider(value: $brightness, in: 0.5...1.5)
                Text(String(format: "%.0f%%", brightness * 100))
                    .frame(width: 50)
                    .font(.caption)
            }

            // Contrast
            HStack {
                Image(systemName: "circle.lefthalf.filled")
                    .frame(width: 30)
                Slider(value: $contrast, in: 0.5...1.5)
                Text(String(format: "%.0f%%", contrast * 100))
                    .frame(width: 50)
                    .font(.caption)
            }

            // Rotation
            HStack {
                Button(action: { rotation -= 90 }) {
                    Image(systemName: "rotate.left")
                }
                .buttonStyle(.bordered)

                Spacer()

                Text("Rotate")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: { rotation += 90 }) {
                    Image(systemName: "rotate.right")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(12)
        .background(Color(nsColor: .textBackgroundColor))
        .cornerRadius(10)
    }

    private var hasAdjustments: Bool {
        brightness != 1.0 || contrast != 1.0 || rotation != 0
    }

    private func resetAdjustments() {
        brightness = 1.0
        contrast = 1.0
        rotation = 0
        currentImage = image
    }

    private func applyFilters() {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
        guard let filter = CIFilter(name: "CIColorControls") else { return }

        let ciImage = CIImage(cgImage: cgImage)
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(brightness, forKey: kCIInputBrightnessKey)
        filter.setValue(contrast, forKey: kCIInputContrastKey)

        guard let outputImage = filter.outputImage else { return }

        let context = CIContext()
        guard let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }

        currentImage = NSImage(cgImage: outputCGImage, size: image.size)
    }

    private func applyRotation() {
        // Rotation is applied via the view transform, so we don't need to modify the image
    }
}

// MARK: - Batch Photo Mode

struct BatchCaptureMode: View {
    @Binding var isActive: Bool
    @Binding var photoCount: Int
    let targetCount: Int
    let onComplete: () -> Void

    var progress: Double {
        Double(photoCount) / Double(targetCount)
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "camera.fill")
                    .foregroundColor(.orange)
                Text("Batch Mode")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button("Exit") {
                    isActive = false
                }
                .buttonStyle(.bordered)
            }

            VStack(spacing: 8) {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(.orange)

                HStack {
                    Text("\(photoCount) of \(targetCount) photos")
                        .font(.caption)
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }

            if photoCount >= targetCount {
                Button(action: onComplete) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Complete Batch")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
    }
}

// MARK: - Photo Annotation Tools

struct PhotoAnnotationView: View {
    @Environment(\.dismiss) private var dismiss
    let image: NSImage
    let onSave: (NSImage) -> Void

    @State private var annotations: [Annotation] = []
    @State private var selectedTool: AnnotationTool = .arrow
    @State private var drawingPath: [CGPoint] = []
    @State private var showTextInput = false
    @State private var textInput = ""

    enum AnnotationTool: String, CaseIterable {
        case arrow = "Arrow"
        case draw = "Draw"
        case text = "Text"
        case highlight = "Highlight"

        var icon: String {
            switch self {
            case .arrow: return "arrow.up.right"
            case .draw: return "pencil"
            case .text: return "textformat"
            case .highlight: return "highlighter"
            }
        }
    }

    struct Annotation: Identifiable {
        let id = UUID()
        let type: AnnotationTool
        let points: [CGPoint]
        let text: String?
        let color: NSColor
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel") {
                    dismiss()
                }

                Spacer()

                Text("Annotate Photo")
                    .font(.headline)

                Spacer()

                Button("Save") {
                    saveAnnotatedImage()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Canvas
            ZStack {
                Color.black

                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                // Annotations overlay
                Canvas { context, size in
                    for annotation in annotations {
                        drawAnnotation(annotation, in: context, size: size)
                    }

                    // Current drawing
                    if !drawingPath.isEmpty {
                        var path = Path()
                        path.addLines(drawingPath)
                        context.stroke(path, with: .color(.red), lineWidth: 3)
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        drawingPath.append(value.location)
                    }
                    .onEnded { _ in
                        if selectedTool == .draw && !drawingPath.isEmpty {
                            annotations.append(Annotation(
                                type: .draw,
                                points: drawingPath,
                                text: nil,
                                color: .red
                            ))
                            drawingPath.removeAll()
                        }
                    }
            )

            Divider()

            // Tools
            HStack(spacing: 20) {
                ForEach(AnnotationTool.allCases, id: \.self) { tool in
                    Button(action: { selectedTool = tool }) {
                        VStack(spacing: 4) {
                            Image(systemName: tool.icon)
                                .font(.title3)
                            Text(tool.rawValue)
                                .font(.caption)
                        }
                        .foregroundColor(selectedTool == tool ? .blue : .primary)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Button(action: { annotations.removeAll() }) {
                    Label("Clear All", systemImage: "trash")
                }
                .buttonStyle(.bordered)
                .disabled(annotations.isEmpty)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .frame(minWidth: 700, minHeight: 700)
    }

    private func drawAnnotation(_ annotation: Annotation, in context: GraphicsContext, size: CGSize) {
        switch annotation.type {
        case .draw:
            var path = Path()
            path.addLines(annotation.points)
            context.stroke(path, with: .color(Color(nsColor: annotation.color)), lineWidth: 3)

        case .arrow:
            if annotation.points.count >= 2 {
                let start = annotation.points.first!
                let end = annotation.points.last!
                var path = Path()
                path.move(to: start)
                path.addLine(to: end)
                context.stroke(path, with: .color(.red), lineWidth: 3)
            }

        case .text, .highlight:
            break
        }
    }

    private func saveAnnotatedImage() {
        // TODO: Composite annotations onto image
        onSave(image)
        dismiss()
    }
}

// MARK: - Enhanced Camera Guidance

struct CameraGuidanceOverlay: View {
    let captureMode: CaptureMode

    enum CaptureMode {
        case general
        case damage
        case measurements
        case before
        case after
    }

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: iconForMode)
                            .font(.title3)
                        Text(titleForMode)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    ForEach(tipsForMode, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                                .font(.caption)
                            Text(tip)
                                .font(.caption)
                        }
                    }
                }
                .foregroundColor(.white)
                .padding(16)
                .background(Color.black.opacity(0.6))
                .cornerRadius(12)
                .padding(16)

                Spacer()
            }

            Spacer()
        }
    }

    private var iconForMode: String {
        switch captureMode {
        case .general: return "camera.fill"
        case .damage: return "exclamationmark.triangle.fill"
        case .measurements: return "ruler.fill"
        case .before: return "photo.fill"
        case .after: return "checkmark.circle.fill"
        }
    }

    private var titleForMode: String {
        switch captureMode {
        case .general: return "Photo Capture Tips"
        case .damage: return "Documenting Damage"
        case .measurements: return "Measurement Photos"
        case .before: return "Before Photos"
        case .after: return "After Photos"
        }
    }

    private var tipsForMode: [String] {
        switch captureMode {
        case .general:
            return [
                "Hold device steady",
                "Ensure good lighting",
                "Capture multiple angles"
            ]
        case .damage:
            return [
                "Get close-up of damage",
                "Include surrounding area",
                "Use flash if needed"
            ]
        case .measurements:
            return [
                "Include measuring tape",
                "Photo should be level",
                "Avoid parallax distortion"
            ]
        case .before:
            return [
                "Capture entire work area",
                "Document existing conditions",
                "Note any pre-existing issues"
            ]
        case .after:
            return [
                "Same angles as before photos",
                "Show completed work clearly",
                "Highlight quality details"
            ]
        }
    }
}

// MARK: - Photo Gallery Improvements

struct EnhancedPhotoGalleryView: View {
    let photos: [NSImage]
    @State private var selectedPhotoIndex: Int?
    @State private var showAnnotation = false
    @State private var showReview = false

    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Photos (\(photos.count))")
                    .font(.headline)
                Spacer()
                Button("Add Photos") {
                    // Open camera
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            Divider()

            if photos.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                            photoThumbnail(photo: photo, index: index)
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(item: $selectedPhotoIndex) { index in
            if index < photos.count {
                photoDetailView(photo: photos[index], index: index)
            }
        }
    }

    private func photoThumbnail(photo: NSImage, index: Int) -> some View {
        Button(action: { selectedPhotoIndex = index }) {
            ZStack(alignment: .bottomTrailing) {
                Image(nsImage: photo)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text("\(index + 1)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
                    .padding(8)
            }
        }
        .buttonStyle(.plain)
    }

    private func photoDetailView(photo: NSImage, index: Int) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("Photo \(index + 1) of \(photos.count)")
                    .font(.headline)
                Spacer()
                Button("Annotate") {
                    showAnnotation = true
                }
                .buttonStyle(.bordered)
                Button("Edit") {
                    showReview = true
                }
                .buttonStyle(.bordered)
            }
            .padding()

            Image(nsImage: photo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
        }
        .frame(minWidth: 700, minHeight: 700)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No Photos Yet")
                .font(.headline)
            Text("Capture photos to document the job site")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Helper extension for selectedPhotoIndex
extension Int: Identifiable {
    public var id: Int { self }
}

#Preview {
    EnhancedPhotoGalleryView(photos: [])
}
