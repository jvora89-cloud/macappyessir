//
//  WorkingCameraView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/5/26.
//

import SwiftUI

struct WorkingCameraView: View {
    @Binding var isPresented: Bool
    @State private var cameraManager = CameraManager()
    @State private var capturedPhotos: [NSImage] = []
    var onPhotosCaptured: (([NSImage]) -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Header
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

                    Button(action: {}) {
                        VStack(spacing: 4) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .font(.title3)
                            Text("Flip")
                                .font(.caption)
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.white)
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
}

#Preview {
    WorkingCameraView(isPresented: .constant(true))
}
