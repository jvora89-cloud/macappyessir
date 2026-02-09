//
//  SuccessToast.swift
//  macappyessir
//
//  Created by Jay Vora on 2/8/26.
//

import SwiftUI
import Combine

struct SuccessToast: View {
    let message: String
    let icon: String
    @Binding var isShowing: Bool

    var body: some View {
        if isShowing {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)

                Text(message)
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
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        isShowing = false
                    }
                }
            }
        }
    }
}

// Global toast manager
class ToastManager: ObservableObject {
    @Published var showToast = false
    @Published var toastMessage = ""
    @Published var toastIcon = "checkmark.circle.fill"

    func show(message: String, icon: String = "checkmark.circle.fill") {
        toastMessage = message
        toastIcon = icon
        withAnimation {
            showToast = true
        }
    }
}

#Preview {
    @Previewable @State var showing = true

    VStack {
        Spacer()
        SuccessToast(
            message: "Job created successfully!",
            icon: "checkmark.circle.fill",
            isShowing: $showing
        )
        Spacer()
    }
}
