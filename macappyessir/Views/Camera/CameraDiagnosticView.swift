//
//  CameraDiagnosticView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/7/26.
//  Diagnostic view to debug camera issues
//

import SwiftUI
import AVFoundation

struct CameraDiagnosticView: View {
    @State private var cameraManager = CameraManager()
    @State private var diagnosticInfo: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Camera Diagnostic Tool")
                .font(.title)
                .fontWeight(.bold)

            Divider()

            // Authorization Status
            HStack {
                Image(systemName: cameraManager.isAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(cameraManager.isAuthorized ? .green : .red)
                Text("Camera Authorization:")
                Text(cameraManager.isAuthorized ? "Authorized" : "Not Authorized")
                    .fontWeight(.semibold)
            }

            // Available Cameras
            VStack(alignment: .leading, spacing: 8) {
                Text("Available Cameras: \(cameraManager.availableCameras.count)")
                    .fontWeight(.semibold)

                ForEach(cameraManager.availableCameras.indices, id: \.self) { index in
                    let camera = cameraManager.availableCameras[index]
                    HStack {
                        Image(systemName: camera.uniqueID == cameraManager.selectedCamera?.uniqueID ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(camera.uniqueID == cameraManager.selectedCamera?.uniqueID ? .green : .gray)
                        VStack(alignment: .leading) {
                            Text(camera.localizedName)
                            Text(cameraManager.cameraTypeDescription(for: camera))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.leading, 20)
                }

                if cameraManager.availableCameras.isEmpty {
                    Text("No cameras detected")
                        .foregroundColor(.red)
                        .padding(.leading, 20)
                }
            }

            // Selected Camera
            HStack {
                Image(systemName: "camera.fill")
                Text("Selected Camera:")
                if let selected = cameraManager.selectedCamera {
                    Text(selected.localizedName)
                        .fontWeight(.semibold)
                } else {
                    Text("None")
                        .foregroundColor(.red)
                }
            }

            // Session Status
            HStack {
                Image(systemName: cameraManager.isSessionRunning ? "play.circle.fill" : "pause.circle.fill")
                    .foregroundColor(cameraManager.isSessionRunning ? .green : .orange)
                Text("Session Running:")
                Text(cameraManager.isSessionRunning ? "Yes" : "No")
                    .fontWeight(.semibold)
            }

            // Error Message
            if let error = cameraManager.errorMessage {
                VStack(alignment: .leading) {
                    Text("Error:")
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }

            Divider()

            // System Info
            VStack(alignment: .leading, spacing: 8) {
                Text("System Information")
                    .fontWeight(.semibold)

                Text("macOS Version: \(ProcessInfo.processInfo.operatingSystemVersionString)")
                    .font(.caption)
                Text("Device Model: \(getDeviceModel())")
                    .font(.caption)
            }

            Divider()

            // Actions
            HStack(spacing: 12) {
                Button("Refresh Camera") {
                    cameraManager.discoverCameras()
                    if cameraManager.isAuthorized {
                        cameraManager.setupCamera()
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Request Permission") {
                    cameraManager.checkAuthorization()
                }
                .buttonStyle(.bordered)

                Button("Open System Settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            // Diagnostic Logs
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Diagnostic Logs")
                        .fontWeight(.semibold)
                    ForEach(diagnosticInfo, id: \.self) { info in
                        Text(info)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxHeight: 200)
            .padding()
            .background(Color(nsColor: .textBackgroundColor))
            .cornerRadius(8)
        }
        .padding()
        .frame(minWidth: 600, minHeight: 800)
        .onAppear {
            collectDiagnosticInfo()
        }
    }

    private func collectDiagnosticInfo() {
        diagnosticInfo.removeAll()

        diagnosticInfo.append("=== Camera Diagnostic Started ===")
        diagnosticInfo.append("Date: \(Date())")

        // Check authorization
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        diagnosticInfo.append("Authorization Status: \(authStatus.rawValue)")

        // Discover cameras
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

        diagnosticInfo.append("Cameras Found: \(discoverySession.devices.count)")
        for (index, camera) in discoverySession.devices.enumerated() {
            diagnosticInfo.append("  \(index + 1). \(camera.localizedName)")
            diagnosticInfo.append("     Type: \(camera.deviceType.rawValue)")
            diagnosticInfo.append("     ID: \(camera.uniqueID)")
            diagnosticInfo.append("     Position: \(camera.position.rawValue)")
        }

        // Check for built-in camera specifically
        let builtInCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified)
        diagnosticInfo.append("Built-in Camera Available: \(builtInCamera != nil ? "Yes" : "No")")

        if let camera = builtInCamera {
            diagnosticInfo.append("  Name: \(camera.localizedName)")
            diagnosticInfo.append("  Active: \(camera.isConnected)")
        }

        diagnosticInfo.append("=== Diagnostic Complete ===")
    }

    private func getDeviceModel() -> String {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
    }
}

#Preview {
    CameraDiagnosticView()
}
