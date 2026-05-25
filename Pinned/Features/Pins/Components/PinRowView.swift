//
//  PinRowView.swift
//  Pinned
//
//  Created by Michał Wolanin on 22/05/2026.
//

import SwiftUI

struct PinRowView: View {
    let pinSet: PinSet
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(pinSet.domain)
                        .plexStyle(.pinnedBody.with(color: .primaryText))
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer(minLength: 8)

                    if pinSet.includeSubdomains {
                        Text(.PinRow.subdomainsBadge)
                            .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.6)))
                    }
                }

                Text(.PinRow.pinCount(pinSet.hashes.count))
                    .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.55)))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard()
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview("Pin Row") {
    ZStack {
        Color.primaryBackground.ignoresSafeArea()
        VStack(spacing: 8) {
            PinRowView(
                pinSet: PinSet(
                    domain: "api.example.com",
                    hashes: ["r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E="],
                    includeSubdomains: true
                ),
                onTap: {},
                onDelete: {}
            )
            PinRowView(
                pinSet: PinSet(
                    domain: "api.github.com",
                    hashes: [
                        "ZqQk/sJxFf6jUNFCCXJZpEPmRZj5wK7lXJpkN8YHWvA=",
                        "x/Q42aFnL5LBjQQqYxHmZf0vM9wD4XGqzPKnTSqL1Pk="
                    ]
                ),
                onTap: {},
                onDelete: {}
            )
        }
        .padding()
    }
    .preferredColorScheme(.light)
}
