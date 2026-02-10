//
//  DesignSystem.swift
//  macappyessir
//
//  Created by Jay Vora on 2/9/26.
//

import SwiftUI

/// QuoteHub Design System - Consistent visual language across the app
enum DesignSystem {

    // MARK: - Typography
    enum Typography {
        /// Large page titles (32pt, bold)
        static func pageTitle() -> Font {
            .system(size: 32, weight: .bold)
        }

        /// Section headings (22pt, semibold)
        static func sectionHeading() -> Font {
            .system(size: 22, weight: .semibold)
        }

        /// Card titles (18pt, semibold)
        static func cardTitle() -> Font {
            .system(size: 18, weight: .semibold)
        }

        /// Body text (14pt, regular)
        static func body() -> Font {
            .system(size: 14, weight: .regular)
        }

        /// Small labels (12pt, medium)
        static func label() -> Font {
            .system(size: 12, weight: .medium)
        }

        /// Captions (11pt, regular)
        static func caption() -> Font {
            .system(size: 11, weight: .regular)
        }
    }

    // MARK: - Colors
    enum Colors {
        static let primary = Color.blue
        static let secondary = Color.orange
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red

        /// Background colors
        static let backgroundPrimary = Color(nsColor: .windowBackgroundColor)
        static let backgroundSecondary = Color(nsColor: .controlBackgroundColor)
        static let backgroundTertiary = Color(nsColor: .textBackgroundColor)

        /// Text colors
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let textTertiary = Color(white: 0.6)

        /// Gradient used throughout the app
        static let brandGradient = LinearGradient(
            colors: [.orange, .blue],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 40
    }

    // MARK: - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let xlarge: CGFloat = 16
    }

    // MARK: - Shadows
    enum Shadows {
        static func card() -> some View {
            EmptyView()
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }

        static func button() -> some View {
            EmptyView()
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }

        static func modal() -> some View {
            EmptyView()
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
    }

    // MARK: - Layout
    enum Layout {
        /// Standard padding for main content areas
        static let contentPadding: CGFloat = 24

        /// Standard padding for cards/sections
        static let cardPadding: CGFloat = 20

        /// Maximum content width for readability
        static let maxContentWidth: CGFloat = 1200

        /// Sidebar width
        static let sidebarWidth: CGFloat = 70
    }
}

// MARK: - View Extensions
extension View {
    /// Apply standard card styling
    func cardStyle() -> some View {
        self
            .padding(DesignSystem.Layout.cardPadding)
            .background(DesignSystem.Colors.backgroundSecondary)
            .cornerRadius(DesignSystem.CornerRadius.large)
    }

    /// Apply standard section styling
    func sectionStyle() -> some View {
        self
            .padding(DesignSystem.Spacing.lg)
            .background(DesignSystem.Colors.backgroundSecondary)
            .cornerRadius(DesignSystem.CornerRadius.large)
    }

    /// Apply page padding
    func pagePadding() -> some View {
        self.padding(DesignSystem.Layout.contentPadding)
    }
}

// MARK: - Preview
#Preview("Typography") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Page Title")
            .font(DesignSystem.Typography.pageTitle())

        Text("Section Heading")
            .font(DesignSystem.Typography.sectionHeading())

        Text("Card Title")
            .font(DesignSystem.Typography.cardTitle())

        Text("Body Text - The quick brown fox jumps over the lazy dog")
            .font(DesignSystem.Typography.body())

        Text("Label Text")
            .font(DesignSystem.Typography.label())

        Text("Caption Text")
            .font(DesignSystem.Typography.caption())
    }
    .padding()
}

#Preview("Colors") {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            ColorSwatch(color: DesignSystem.Colors.primary, name: "Primary")
            ColorSwatch(color: DesignSystem.Colors.secondary, name: "Secondary")
        }

        HStack(spacing: 16) {
            ColorSwatch(color: DesignSystem.Colors.success, name: "Success")
            ColorSwatch(color: DesignSystem.Colors.warning, name: "Warning")
            ColorSwatch(color: DesignSystem.Colors.error, name: "Error")
        }
    }
    .padding()
}

struct ColorSwatch: View {
    let color: Color
    let name: String

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 80, height: 80)

            Text(name)
                .font(.caption)
        }
    }
}
