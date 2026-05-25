//
//  UpsertHashRow.swift
//  Pinned
//
//  Created by Michał Wolanin on 24/05/2026.
//

import SwiftUI

struct UpsertHashRow: View {
    let hash: String
    let onDelete: () -> Void

    @State private var didCopy = false

    var body: some View {
        HStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                Text(hash)
                    .plexStyle(.pinnedHash.with(color: .primaryText))
                    .textSelection(.enabled)
                    .padding(.horizontal, 6)
            }
            .scrollClipDisabled(false)

            Spacer(minLength: 0)

            copyButton

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.primaryText.opacity(0.65))
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 14)
        .padding(.trailing, 6)
        .frame(height: 44)
        .glassCard()
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var copyButton: some View {
        Button(action: copy) {
            Image(systemName: didCopy ? "checkmark" : "doc.on.doc")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.primaryText.opacity(0.65))
                .frame(width: 24, height: 24)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .disabled(didCopy)
    }

    private func copy() {
        UIPasteboard.general.string = hash

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            didCopy = true
        }

        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                didCopy = false
            }
        }
    }
}

#Preview("Hash Row") {
    ZStack {
        Color.primaryBackground.ignoresSafeArea()
        VStack(spacing: 8) {
            UpsertHashRow(
                hash: "r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E=",
                onDelete: {}
            )
            UpsertHashRow(
                hash: "YZPgTZ+woNCCCIW3LH2CxQeLzB/0pxKj2KkmF5pj9rE=",
                onDelete: {}
            )
            UpsertHashRow(
                hash: "x/Q42aFnL5LBjQQqYxHmZf0vM9wD4XGqzPKnTSqL1Pk=",
                onDelete: {}
            )
        }
        .padding(20)
    }
    .preferredColorScheme(.light)
}
