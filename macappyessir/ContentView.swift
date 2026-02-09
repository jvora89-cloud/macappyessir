//
//  ContentView.swift
//  macappyessir
//
//  Created by Jay Vora on 2/1/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack(alignment: .top) {
            HStack(spacing: 0) {
                // Main content area
                Group {
                    switch appState.selectedItem {
                    case .dashboard:
                        DashboardView()
                    case .newEstimate:
                        NewEstimateView()
                    case .activeJobs:
                        ActiveJobsView()
                    case .completed:
                        CompletedJobsView()
                    case .settings:
                        SettingsView()
                    case .none:
                        DashboardView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()

                RightSidebar()
                    .frame(width: 70)
            }

            // Toast notification
            if appState.toastManager.showToast {
                VStack {
                    HStack(spacing: 12) {
                        Image(systemName: appState.toastManager.toastIcon)
                            .font(.title3)
                            .foregroundColor(.white)

                        Text(appState.toastManager.toastMessage)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.green)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                .padding(.top, 20)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
