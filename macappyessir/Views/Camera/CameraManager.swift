//
//  CameraManager.swift
//  macappyessir
//
//  Created by Jay Vora on 2/5/26.
//  Enhanced for multi-device camera support
//

import AVFoundation
import AppKit
import SwiftUI

@Observable
class CameraManager: NSObject {
    var session: AVCaptureSession?
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var capturedImage: NSImage?
    var isAuthorized = false
    var isProcessing = false
    var errorMessage: String?
    var isSessionRunning = false

    // Multi-device support
    var availableCameras: [AVCaptureDevice] = []
    var selectedCamera: AVCaptureDevice?
    var currentInput: AVCaptureDeviceInput?

    override init() {
        super.init()
        checkAuthorization()
    }

    func checkAuthorization() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        print("📹 Camera authorization status: \(status.rawValue)")

        switch status {
        case .authorized:
            print("✅ Camera access authorized")
            isAuthorized = true
            discoverCameras()
            setupCamera()
        case .notDetermined:
            print("⚠️ Camera access not determined, requesting...")
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        print("✅ Camera access granted by user")
                        self?.discoverCameras()
                        self?.setupCamera()
                    } else {
                        print("❌ Camera access denied by user")
                        self?.errorMessage = "Camera access denied. Please enable in System Settings → Privacy & Security → Camera"
                    }
                }
            }
        case .denied:
            print("❌ Camera access denied")
            isAuthorized = false
            errorMessage = "Camera access denied. Please enable in System Settings → Privacy & Security → Camera"
        case .restricted:
            print("❌ Camera access restricted")
            isAuthorized = false
            errorMessage = "Camera access is restricted. Please check device restrictions."
        @unknown default:
            print("⚠️ Unknown camera authorization status")
            isAuthorized = false
            errorMessage = "Unknown camera authorization status"
        }
    }

    func discoverCameras() {
        // Discover all available camera devices
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInWideAngleCamera,  // MacBook built-in camera
                .external,                 // External USB cameras
                .continuityCamera,         // iPhone/iPad via Continuity Camera
                .deskViewCamera           // iPhone with Desk View (iOS 16+)
            ],
            mediaType: .video,
            position: .unspecified
        )

        availableCameras = discoverySession.devices

        // Log available cameras
        print("📸 Available Cameras:")
        for (index, camera) in availableCameras.enumerated() {
            let type = cameraTypeDescription(for: camera)
            print("  \(index + 1). \(camera.localizedName) [\(type)]")
        }

        // Select best available camera (prefer Continuity Camera or built-in)
        if availableCameras.isEmpty {
            errorMessage = "No cameras found. For desktops, connect a USB camera or use iPhone via Continuity Camera."
        } else {
            // Priority: Continuity Camera > Built-in > External
            selectedCamera = availableCameras.first(where: { $0.deviceType == .continuityCamera })
                          ?? availableCameras.first(where: { $0.deviceType == .builtInWideAngleCamera })
                          ?? availableCameras.first

            if let selected = selectedCamera {
                print("✅ Selected camera: \(selected.localizedName)")
            }
        }
    }

    func cameraTypeDescription(for device: AVCaptureDevice) -> String {
        switch device.deviceType {
        case .builtInWideAngleCamera:
            return "Built-in Camera"
        case .continuityCamera:
            return "iPhone/iPad (Continuity)"
        case .deskViewCamera:
            return "iPhone Desk View"
        case .external:
            return "External Camera"
        default:
            return "Camera"
        }
    }

    func switchCamera(to device: AVCaptureDevice) {
        // Check if device is in available cameras using uniqueID
        guard availableCameras.contains(where: { $0.uniqueID == device.uniqueID }) else {
            print("⚠️ Camera not in available cameras list")
            return
        }

        print("🔄 Switching to camera: \(device.localizedName)")
        selectedCamera = device

        // Restart camera with new device
        if let session = session, session.isRunning {
            stopCamera()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.setupCamera()
            }
        } else {
            setupCamera()
        }
    }

    func setupCamera() {
        print("🔧 Setting up camera...")

        guard let selectedCamera = selectedCamera else {
            errorMessage = "No camera available"
            print("❌ No camera selected")
            return
        }

        print("📹 Configuring camera: \(selectedCamera.localizedName)")

        // Clean up existing session if switching cameras
        if let existingSession = session {
            existingSession.stopRunning()
            if let currentInput = currentInput {
                existingSession.removeInput(currentInput)
            }
            if let photoOutput = photoOutput {
                existingSession.removeOutput(photoOutput)
            }
        }

        session = AVCaptureSession()
        guard let session = session else {
            errorMessage = "Failed to create capture session"
            print("❌ Failed to create session")
            return
        }

        session.beginConfiguration()

        // Try different presets in order of preference
        if session.canSetSessionPreset(.photo) {
            session.sessionPreset = .photo
            print("✅ Using .photo preset")
        } else if session.canSetSessionPreset(.high) {
            session.sessionPreset = .high
            print("✅ Using .high preset")
        } else {
            session.sessionPreset = .medium
            print("⚠️ Using .medium preset")
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: selectedCamera)
            currentInput = videoInput

            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                print("✅ Added video input: \(selectedCamera.localizedName)")
            } else {
                errorMessage = "Cannot add camera input to session"
                print("❌ Cannot add video input")
                session.commitConfiguration()
                return
            }

            // Setup photo output
            photoOutput = AVCapturePhotoOutput()
            if let photoOutput = photoOutput, session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)

                // Configure for high quality
                if #available(macOS 13.0, *) {
                    // Get the highest supported dimensions from the active format
                    if let format = selectedCamera.activeFormat.supportedMaxPhotoDimensions.max(by: {
                        ($0.width * $0.height) < ($1.width * $1.height)
                    }) {
                        photoOutput.maxPhotoDimensions = format
                        print("✅ Set max photo dimensions: \(format.width)x\(format.height)")
                    }
                } else {
                    photoOutput.isHighResolutionCaptureEnabled = true
                }

                print("✅ Added photo output")
            } else {
                print("⚠️ Could not add photo output")
            }

            session.commitConfiguration()

            // Clear any previous errors
            errorMessage = nil

            // Start session on background thread
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                print("▶️ Starting camera session...")
                session.startRunning()

                DispatchQueue.main.async {
                    self?.isSessionRunning = session.isRunning
                    if session.isRunning {
                        print("✅ Camera session started successfully")
                        self?.errorMessage = nil
                    } else {
                        self?.errorMessage = "Camera failed to start. Please check camera permissions."
                        print("❌ Camera session failed to start")
                    }
                }
            }
        } catch let error as NSError {
            let errorMsg = "Camera error: \(error.localizedDescription)"
            errorMessage = errorMsg
            print("❌ Error setting up camera: \(error)")
            print("   Error domain: \(error.domain)")
            print("   Error code: \(error.code)")
            if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? Error {
                print("   Underlying error: \(underlyingError)")
            }
            session.commitConfiguration()
        }
    }

    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }

        isProcessing = true

        let settings = AVCapturePhotoSettings()

        // High quality settings
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            settings.photoQualityPrioritization = .quality
        }

        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func stopCamera() {
        print("⏹️ Stopping camera session")
        session?.stopRunning()
        isSessionRunning = false
    }

    // Get camera device info for UI
    func getCameraInfo() -> String {
        guard let selectedCamera = selectedCamera else {
            return "No camera selected"
        }

        let type = cameraTypeDescription(for: selectedCamera)
        return "\(selectedCamera.localizedName) (\(type))"
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            isProcessing = false
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = NSImage(data: imageData) else {
            isProcessing = false
            return
        }

        DispatchQueue.main.async {
            self.capturedImage = image
            self.isProcessing = false
        }
    }
}
