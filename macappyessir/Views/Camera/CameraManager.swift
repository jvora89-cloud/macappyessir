//
//  CameraManager.swift
//  macappyessir
//
//  Created by Jay Vora on 2/5/26.
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

    override init() {
        super.init()
        checkAuthorization()
    }

    func checkAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.setupCamera()
                    }
                }
            }
        default:
            isAuthorized = false
        }
    }

    func setupCamera() {
        session = AVCaptureSession()
        guard let session = session else {
            errorMessage = "Failed to create capture session"
            return
        }

        session.beginConfiguration()
        session.sessionPreset = .photo

        // Get camera device
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .externalUnknown],
            mediaType: .video,
            position: .unspecified
        )

        guard let videoDevice = discoverySession.devices.first else {
            errorMessage = "No camera found. Please connect a camera."
            print("❌ No camera devices found")
            print("Available devices: \(AVCaptureDevice.devices())")
            session.commitConfiguration()
            return
        }

        print("✅ Found camera: \(videoDevice.localizedName)")

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                print("✅ Added video input")
            } else {
                errorMessage = "Cannot add camera input"
                print("❌ Cannot add video input")
            }

            // Setup photo output
            photoOutput = AVCapturePhotoOutput()
            if let photoOutput = photoOutput, session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
                print("✅ Added photo output")
            }

            session.commitConfiguration()

            // Start session on background thread
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                session.startRunning()
                DispatchQueue.main.async {
                    self?.isSessionRunning = session.isRunning
                    if session.isRunning {
                        print("✅ Camera session started successfully")
                    } else {
                        self?.errorMessage = "Camera failed to start"
                        print("❌ Camera session failed to start")
                    }
                }
            }
        } catch {
            errorMessage = "Camera error: \(error.localizedDescription)"
            print("❌ Error setting up camera: \(error)")
            session.commitConfiguration()
        }
    }

    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }

        isProcessing = true

        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func stopCamera() {
        session?.stopRunning()
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
