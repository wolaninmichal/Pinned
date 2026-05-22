//
//  PinsView.swift
//  Pinned
//
//  Created by Michał Wolanin on 15/05/2026.
//

import SwiftUI

struct PinsView: View {

    let vm: PinsViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, 26)
                    .padding(.bottom, 18)

                placeholder
                    .padding(.top, 60)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - Subviews
private extension PinsView {

    var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(.Pins.eyebrow)
                    .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.55)))
                    .tracking(1.2)

                Text(.Pins.title)
                    .plexStyle(.pinnedTitle.with(color: .primaryText))
            }

            Spacer()

            addButton
        }
    }

    var addButton: some View {
        Button {

        } label: {
            Image(systemName: "plus")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.primaryText)
                .frame(width: 36, height: 36)
                .glassCard(.elevated, cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }

    var placeholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "pin.slash")
                .font(.system(size: 28))
                .foregroundStyle(Color.primaryText.opacity(0.55))

            VStack(spacing: 4) {
                Text(.Pins.emptyTitle)
                    .plexStyle(.pinnedBody.with(color: .primaryText))
                Text(.Pins.emptyMessage)
                    .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.6)))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Pins View") {
    ZStack {
        Color.primaryBackground.ignoresSafeArea()
        PinsView(vm: .init())
    }
    .preferredColorScheme(.light)
}
