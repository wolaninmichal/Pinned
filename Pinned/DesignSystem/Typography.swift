//
//  Typography.swift
//  Pinned
//
//  Created by Michał Wolanin on 12/05/2026.
//

import SwiftUI

public extension Font {
    static func plexMono(
        _ size: CGFloat,
        weight: Font.Weight = .regular
    ) -> Font {
        let name: String

        switch weight {
        case .thin:
            name = "IBMPlexMono-Thin"
        case .regular:
            name = "IBMPlexMono-Regular"
        case .medium:
            name = "IBMPlexMono-Medium"
        case .semibold:
            name = "IBMPlexMono-SemiBold"
        case .bold:
            name = "IBMPlexMono-Bold"
        default:
            name = "IBMPlexMono-Regular"
        }

        return .custom(name, size: size)
    }

    static let pinnedTitle = plexMono(36, weight: .bold)
    static let pinnedHeading = plexMono(13, weight: .medium)
    static let pinnedBody = plexMono(13)
    static let pinnedCaption = plexMono(11)
    static let pinnedHash = plexMono(12, weight: .medium)
}

#Preview("Plex Mono Fonts") {
    VStack(alignment: .leading, spacing: 16) {
        Text("Pinned Title")
            .font(.pinnedTitle)

        Text("PINNED HEADING")
            .font(.pinnedHeading)

        Text("Pinned body text example")
            .font(.pinnedBody)

        Text("Pinned caption")
            .font(.pinnedCaption)

        Text("#pinnedHash")
            .font(.pinnedHash)
    }
    .padding()
}
