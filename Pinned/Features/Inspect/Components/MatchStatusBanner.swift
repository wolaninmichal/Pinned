//
//  MatchStatusBanner.swift
//  Pinned
//
//  Created by Michał Wolanin on 22/05/2026.
//

import SwiftUI

struct MatchStatusBanner: View {
    let result: MatchResult

    var body: some View {
        switch result {
        case .matched(let level):
            banner(
                icon: "checkmark",
                title: .Match.matchedTitle,
                subtitle: .Match.matchedSubtitle(levelDescription(level)),
                tint: .matchSuccess
            )
        case .mismatch:
            banner(
                icon: "xmark",
                title: .Match.mismatchTitle,
                subtitle: .Match.mismatchSubtitle,
                tint: .matchFailure
            )
        case .noPinsForDomain:
            EmptyView()
        }
    }
}

// MARK: - Subviews
private extension MatchStatusBanner {

    func banner(
        icon: String,
        title: LocalizedStringResource,
        subtitle: LocalizedStringResource,
        tint: Color
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.primaryText)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .plexStyle(.pinnedBody.with(color: .primaryText))
                Text(subtitle)
                    .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.75)))
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(tint.opacity(0.18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(tint.opacity(0.45), lineWidth: 0.5)
        )
    }
}

// MARK: - Helpers
private extension MatchStatusBanner {

    func levelDescription(_ level: CertificateChain.Position) -> String {
        switch level {
        case .leaf: String(localized: .Match.levelLeaf)
        case .intermediate(let i): String(localized: .Match.levelIntermediate(i))
        case .root: String(localized: .Match.levelRoot)
        }
    }
}

#Preview("Match Status Banner") {
    ZStack {
        Color.primaryBackground.ignoresSafeArea()
        VStack(spacing: 12) {
            MatchStatusBanner(result: .matched(level: .leaf))
            MatchStatusBanner(result: .matched(level: .intermediate(index: 1)))
            MatchStatusBanner(result: .mismatch)
        }
        .padding()
    }
    .preferredColorScheme(.light)
}
