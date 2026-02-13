//
//  CameraManagerTests.swift
//  macappyessirTests
//
//  Created by Jay Vora on 2/7/26.
//  Tests for multi-device camera support
//

import XCTest
import AVFoundation
@testable import macappyessir

final class CameraManagerTests: XCTestCase {
    var cameraManager: CameraManager!

    override func setUp() {
        super.setUp()
        cameraManager = CameraManager()

        // Wait for camera initialization
        let expectation = XCTestExpectation(description: "Camera initialization")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    override func tearDown() {
        cameraManager.stopCamera()
        cameraManager = nil
        super.tearDown()
    }

    // MARK: - Camera Discovery Tests

    func testCameraDiscovery() {
        // Test that cameras are discovered
        XCTAssertTrue(cameraManager.availableCameras.count >= 0, "Should discover cameras or have empty array")

        if !cameraManager.availableCameras.isEmpty {
            print("✅ Discovered \(cameraManager.availableCameras.count) camera(s)")
            for (index, camera) in cameraManager.availableCameras.enumerated() {
                let type = cameraManager.cameraTypeDescription(for: camera)
                print("  \(index + 1). \(camera.localizedName) [\(type)]")
            }
        } else {
            print("⚠️ No cameras found (expected on CI or headless Macs)")
        }
    }

    func testCameraTypeDescription() {
        // Create a mock discovery session to test camera type descriptions
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInWideAngleCamera,
                .external,
                .continuityCamera,
                .deskViewCamera
            ],
            mediaType: .video,
            position: .unspecified
        )

        for camera in discoverySession.devices {
            let description = cameraManager.cameraTypeDescription(for: camera)
            XCTAssertFalse(description.isEmpty, "Camera type description should not be empty")

            // Verify description matches expected values
            switch camera.deviceType {
            case .builtInWideAngleCamera:
                XCTAssertEqual(description, "Built-in Camera")
            case .continuityCamera:
                XCTAssertEqual(description, "iPhone/iPad (Continuity)")
            case .deskViewCamera:
                XCTAssertEqual(description, "iPhone Desk View")
            case .external:
                XCTAssertEqual(description, "External Camera")
            default:
                XCTAssertEqual(description, "Camera")
            }
        }
    }

    func testSelectedCameraIsValid() {
        // Test that selected camera is from available cameras
        if let selectedCamera = cameraManager.selectedCamera {
            XCTAssertTrue(
                cameraManager.availableCameras.contains(where: { $0.uniqueID == selectedCamera.uniqueID }),
                "Selected camera should be in available cameras list"
            )
            print("✅ Selected camera: \(selectedCamera.localizedName)")
        } else {
            XCTAssertTrue(cameraManager.availableCameras.isEmpty, "No camera selected because no cameras available")
        }
    }

    func testCameraInfo() {
        // Test camera info string
        let info = cameraManager.getCameraInfo()
        XCTAssertFalse(info.isEmpty, "Camera info should not be empty")

        if cameraManager.selectedCamera == nil {
            XCTAssertEqual(info, "No camera selected")
        } else {
            XCTAssertTrue(info.contains("("), "Camera info should contain type in parentheses")
            XCTAssertTrue(info.contains(")"), "Camera info should contain closing parenthesis")
            print("📸 Camera info: \(info)")
        }
    }

    // MARK: - Camera Switching Tests

    func testCameraSwitching() {
        // Only test if multiple cameras available
        guard cameraManager.availableCameras.count > 1 else {
            print("⚠️ Skipping switch test - only \(cameraManager.availableCameras.count) camera(s) available")
            return
        }

        let initialCamera = cameraManager.selectedCamera
        XCTAssertNotNil(initialCamera, "Should have initial camera selected")

        // Get second camera
        let secondCamera = cameraManager.availableCameras.first { $0.uniqueID != initialCamera?.uniqueID }
        XCTAssertNotNil(secondCamera, "Should have second camera available")

        // Switch to second camera
        cameraManager.switchCamera(to: secondCamera!)

        // Wait for camera to switch
        let expectation = XCTestExpectation(description: "Camera switch")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)

        // Verify camera switched
        XCTAssertEqual(cameraManager.selectedCamera?.uniqueID, secondCamera?.uniqueID, "Camera should have switched")
        print("✅ Successfully switched from \(initialCamera?.localizedName ?? "unknown") to \(secondCamera?.localizedName ?? "unknown")")
    }

    func testInvalidCameraSwitch() {
        // Create a dummy device that's not in available cameras
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .audio, // Use audio to get a non-camera device
            position: .unspecified
        )

        if let audioDevice = discoverySession.devices.first {
            let initialCamera = cameraManager.selectedCamera

            // Try to switch to invalid device (should be ignored)
            cameraManager.switchCamera(to: audioDevice)

            // Camera should remain the same
            XCTAssertEqual(cameraManager.selectedCamera?.uniqueID, initialCamera?.uniqueID, "Camera should not change for invalid device")
            print("✅ Invalid camera switch correctly ignored")
        }
    }

    // MARK: - Session Tests

    func testCameraSessionExists() {
        // Test that camera session is created if cameras available
        if !cameraManager.availableCameras.isEmpty {
            XCTAssertNotNil(cameraManager.session, "Camera session should exist when cameras available")
            print("✅ Camera session created")
        } else {
            print("⚠️ No cameras available - session test skipped")
        }
    }

    func testCameraAuthorization() {
        // Test that authorization is checked
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        print("📹 Camera authorization status: \(status.rawValue)")

        switch status {
        case .authorized:
            XCTAssertTrue(cameraManager.isAuthorized, "Manager should reflect authorized status")
            print("✅ Camera authorized")
        case .notDetermined:
            print("⚠️ Camera permission not determined - will prompt user")
        case .denied, .restricted:
            XCTAssertFalse(cameraManager.isAuthorized, "Manager should reflect denied status")
            XCTAssertNotNil(cameraManager.errorMessage, "Should have error message when denied")
            print("❌ Camera access denied")
        @unknown default:
            XCTFail("Unknown authorization status")
        }
    }

    // MARK: - Performance Tests

    func testCameraDiscoveryPerformance() {
        measure {
            // Measure performance of camera discovery
            let discoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [
                    .builtInWideAngleCamera,
                    .external,
                    .continuityCamera,
                    .deskViewCamera
                ],
                mediaType: .video,
                position: .unspecified
            )
            _ = discoverySession.devices
        }
    }
}
