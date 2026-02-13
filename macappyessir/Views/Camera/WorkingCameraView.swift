//
//  WorkingCameraView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/5/26.
//  Enhanced for multi-device camera support
//

import SwiftUI
import AVFoundation

struct WorkingCameraView: View {
    @Binding var isPresented: Bool
    @State private var cameraManager = CameraManager()
    @State private var capturedPhotos: [NSImage] = []
    var onPhotosCaptured: (([NSImage]) -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 0) {
                HStack {
                    Button("Cancel") {
                        cameraManager.stopCamera()
                        isPresented = false
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("AI Camera")
                        .font(.headline)

                    Spacer()

                    Button("Done (\(capturedPhotos.count))") {
                        cameraManager.stopCamera()
                        onPhotosCaptured?(capturedPhotos)
                        isPresented = false
                    }
                    .buttonStyle(.plain)
                    .disabled(capturedPhotos.isEmpty)
                }
                .padding()

                // Camera selector bar
                if !cameraManager.availableCameras.isEmpty {
                    HStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Menu {
                            ForEach(cameraManager.availableCameras, id: \.uniqueID) { camera in
                                Button(action: {
                                    cameraManager.switchCamera(to: camera)
                                }) {
                                    HStack {
                                        Text(camera.localizedName)
                                        Spacer()
                                        Text(cameraManager.cameraTypeDescription(for: camera))
                                            .font(.caption)
                                            .foregroundColor(.secondary)

                                        if camera.uniqueID == cameraManager.selectedCamera?.uniqueID {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(cameraManager.getCameraInfo())
                                    .font(.subheadline)
                                Image(systemName: "chevron.down")
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)

                        if cameraManager.availableCameras.count > 1 {
                            Text("•")
                                .foregroundColor(.secondary)
                                .font(.caption)

                            Text("\(cameraManager.availableCameras.count) cameras available")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                }
            }
            .background(Color(nsColor: .controlBackgroundColor))

            // Camera Preview
            ZStack {
                if let errorMessage = cameraManager.errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)

                        Text("Camera Error")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button("Retry") {
                            cameraManager.errorMessage = nil
                            cameraManager.setupCamera()
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.9))
                } else if cameraManager.isAuthorized, let session = cameraManager.session {
                    CameraPreviewView(session: session)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)

                        Text(cameraManager.isAuthorized ? "Setting up camera..." : "Camera permission required")
                            .font(.headline)
                            .foregroundColor(.white)

                        if !cameraManager.isAuthorized {
                            Text("Please grant camera access to use this feature")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            Button("Open System Settings") {
                                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") {
                                    NSWorkspace.shared.open(url)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(.white)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.9))
                }

                // Processing Overlay
                if cameraManager.isProcessing {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("Analyzing job site...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(40)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(16)
                }

                // Captured Photos Preview (bottom left)
                if !capturedPhotos.isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(capturedPhotos.enumerated()), id: \.offset) { index, image in
                                        Image(nsImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .strokeBorder(Color.white, lineWidth: 2)
                                            )
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            Spacer()
                        }
                        .padding(.bottom, 100)
                    }
                }

                // Instructions overlay (top)
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📸 Frame the job site")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            Text("Take multiple photos for better accuracy")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(16)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(12)
                        .padding(16)
                        Spacer()

                        // Camera type indicator (top right)
                        if let selectedCamera = cameraManager.selectedCamera {
                            VStack(alignment: .trailing, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: cameraIcon(for: selectedCamera))
                                        .font(.caption)
                                    Text(cameraManager.cameraTypeDescription(for: selectedCamera))
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                }
                                if cameraManager.availableCameras.count > 1 {
                                    Text("Tap Switch to change")
                                        .font(.caption2)
                                        .opacity(0.8)
                                }
                            }
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(10)
                            .padding(16)
                        }
                    }
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Camera Controls
            VStack(spacing: 20) {
                Button(action: {
                    cameraManager.capturePhoto()
                }) {
                    ZStack {
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 4)
                            .frame(width: 70, height: 70)

                        Circle()
                            .fill(cameraManager.isProcessing ? Color.gray : Color.orange)
                            .frame(width: 60, height: 60)
                    }
                }
                .buttonStyle(.plain)
                .disabled(cameraManager.isProcessing || !cameraManager.isAuthorized)

                HStack(spacing: 40) {
                    Button(action: {}) {
                        VStack(spacing: 4) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title3)
                            Text("Gallery")
                                .font(.caption)
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.white)

                    Button(action: {
                        // Switch to next available camera
                        guard let currentCamera = cameraManager.selectedCamera,
                              let currentIndex = cameraManager.availableCameras.firstIndex(where: { $0.uniqueID == currentCamera.uniqueID }) else {
                            return
                        }

                        let nextIndex = (currentIndex + 1) % cameraManager.availableCameras.count
                        let nextCamera = cameraManager.availableCameras[nextIndex]
                        cameraManager.switchCamera(to: nextCamera)
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .font(.title3)
                            Text("Switch")
                                .font(.caption)
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.white)
                    .disabled(cameraManager.availableCameras.count <= 1)
                }
            }
            .padding(.vertical, 30)
            .background(Color.black.opacity(0.9))
        }
        .frame(minWidth: 700, minHeight: 800)
        .onChange(of: cameraManager.capturedImage) { oldValue, newValue in
            if let newImage = newValue {
                capturedPhotos.append(newImage)
                // Simulate AI processing
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    cameraManager.capturedImage = nil
                }
            }
        }
        .onDisappear {
            cameraManager.stopCamera()
        }
    }

    // Helper function to get appropriate icon for camera type
    private func cameraIcon(for device: AVCaptureDevice) -> String {
        switch device.deviceType {
        case .builtInWideAngleCamera:
            return "laptopcomputer"
        case .continuityCamera:
            return "iphone"
        case .deskViewCamera:
            return "iphone.and.arrow.forward"
        case .external:
            return "video"
        default:
            return "camera"
        }
    }
}

#Preview {
    WorkingCameraView(isPresented: .constant(true))
}
