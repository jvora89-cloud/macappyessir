//
//  LaunchScreen.swift
//  macappyessir
//
//  Created by Jay Vora on 2/9/26.
//

import SwiftUI

struct LaunchScreen: View {
    @State private var isAnimating = false
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.orange.opacity(0.1), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Logo icon
                ZStack {
                    // Outer circle with gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)

                    // Icon
                    Image(systemName: "quote.bubble.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isAnimating ? 0 : -10))
                }
                .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)

                VStack(spacing: 8) {
                    // App name
                    Text("QuoteHub")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    // Tagline
                    Text("Your Quote Command Center")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isAnimating = true
            }
            withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
                opacity = 1.0
            }
        }
    }
}

#Preview {
    LaunchScreen()
}
