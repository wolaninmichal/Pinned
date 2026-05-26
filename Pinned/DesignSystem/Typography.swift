//
//  Typography.swift
//  Pinned
//
//  Created by Michał Wolanin on 12/05/2026.
//

import SwiftUI

// MARK: - Font factory
public extension Font {
    static func plexMono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .thin: name = "IBMPlexMono-Thin"
        case .medium: name = "IBMPlexMono-Medium"
        case .semibold: name = "IBMPlexMono-SemiBold"
        case .bold: name = "IBMPlexMono-Bold"
        default: name = "IBMPlexMono-Regular"
        }
        return .custom(name, size: size)
    }
}

// MARK: - Token
public struct PlexTextStyle {
    public let font: Font
    public let tracking: CGFloat
    public let lineSpacing: CGFloat
    public let color: Color?

    public init(
        font: Font,
        tracking: CGFloat = -0.3,
        lineSpacing: CGFloat = 0,
        color: Color? = nil
    ) {
        self.font = font
        self.tracking = tracking
        self.lineSpacing = lineSpacing
        self.color = color
    }

    public func with(
        tracking: CGFloat? = nil,
        lineSpacing: CGFloat? = nil,
        color: Color? = nil
    ) -> PlexTextStyle {
        .init(
            font: font,
            tracking: tracking ?? self.tracking,
            lineSpacing: lineSpacing ?? self.lineSpacing,
            color: color ?? self.color
        )
    }
}

// MARK: - Predefined styles

public extension PlexTextStyle {
    static let pinnedTitle = PlexTextStyle(font: .plexMono(36, weight: .bold), tracking: -1.0)
    static let pinnedHeading = PlexTextStyle(font: .plexMono(13, weight: .medium), tracking: -0.4)
    static let pinnedBody = PlexTextStyle(font: .plexMono(13), tracking: -0.6)
    static let pinnedCaption = PlexTextStyle(font: .plexMono(11), tracking: -0.6)
    static let pinnedHash = PlexTextStyle(font: .plexMono(12, weight: .medium), tracking: -0.24)
}

// MARK: - Font aliases (compat)
public extension Font {
    static var pinnedTitle: Font { PlexTextStyle.pinnedTitle.font }
    static var pinnedHeading: Font { PlexTextStyle.pinnedHeading.font }
    static var pinnedBody: Font { PlexTextStyle.pinnedBody.font }
    static var pinnedCaption: Font { PlexTextStyle.pinnedCaption.font }
    static var pinnedHash: Font { PlexTextStyle.pinnedHash.font }
}

// MARK: - API
public extension View {
    func plexStyle(_ style: PlexTextStyle) -> some View {
        self
            .font(style.font)
            .tracking(style.tracking)
            .lineSpacing(style.lineSpacing)
            .foregroundStyle(style.color ?? .primary)
    }
}

#Preview("Plex Mono Styles") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Pinned Title").plexStyle(.pinnedTitle)
        Text("PINNED HEADING").plexStyle(.pinnedHeading)
        Text("Pinned body text example").plexStyle(.pinnedBody)
        Text("Pinned caption").plexStyle(.pinnedCaption)
        Text("#pinnedHash").plexStyle(.pinnedHash)
        Text("Alert heading").plexStyle(.pinnedHeading.with(color: .red))
    }
    .padding()
}
