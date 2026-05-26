//
//  PinsView.swift
//  Pinned
//
//  Created by Michał Wolanin on 15/05/2026.
//

import SwiftUI

struct PinsView: View {
    @Bindable var vm: PinsViewModel

    var body: some View {
        Group {
            if vm.pinSets.isEmpty {
                emptyState
            } else {
                populatedState
            }
        }
        .task { await vm.load() }
        .sheet(item: $vm.route) { route in
            upsert(for: route)
        }
    }
}

// MARK: - States
private extension PinsView {

    var emptyState: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                        .padding(.top, 26)
                        .padding(.bottom, 18)

                    placeholder
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
                .frame(minHeight: proxy.size.height, alignment: .top)
            }
            .scrollIndicators(.hidden)
        }
    }

    var populatedState: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 26)
                .padding(.bottom, 18)

            List {
                ForEach(vm.pinSets) { pinSet in
                    pinRow(pinSet)
                        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task { await vm.delete(pinSet) }
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .contentMargins(.bottom, 100, for: .scrollContent)
        }
    }
}

// MARK: - Subviews
private extension PinsView {

    var header: some View {
        HStack(alignment: .top) {
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
        IconButton("plus") { vm.startCreating() }
    }

    func pinRow(_ pinSet: PinSet) -> some View {
        Button {
            vm.startEditing(pinSet)
        } label: {
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
    }

    var placeholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "pin.slash")
                .font(.system(size: 28))
                .foregroundStyle(Color.primaryText.opacity(0.4))

            VStack(spacing: 4) {
                Text(.Pins.emptyTitle)
                    .plexStyle(.pinnedBody.with(color: .primaryText.opacity(0.6)))
                Text(.Pins.emptyMessage)
                    .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.6)))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func upsert(for route: PinsRoute) -> some View {
        let mode: PinUpsertViewModel.Mode = switch route {
        case .create: .create
        case .edit(let pinSet): .edit(pinSet)
        }

        PinUpsertView(
            vm: PinUpsertViewModel(mode: mode),
            onSave: { pinSet in Task { await vm.save(pinSet) } },
            onCancel: { vm.dismissRoute() }
        )
        .presentationBackground(Color.primaryBackground)
        .presentationDragIndicator(.visible)
    }
}

#Preview("Empty") {
    ZStack {
        Color.primaryBackground.ignoresSafeArea()
        PinsView(vm: PinsViewModel(repository: InMemoryPinRepository()))
    }
    .preferredColorScheme(.light)
}

#Preview("With pins") {
    let repository = InMemoryPinRepository(seed: [
        PinSet(
            domain: "api.example.com",
            hashes: ["r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E="],
            includeSubdomains: true
        ),
        PinSet(
            domain: "api.github.com",
            hashes: [
                "ZqQk/sJxFf6jUNFCCXJZpEPmRZj5wK7lXJpkN8YHWvA=",
                "x/Q42aFnL5LBjQQqYxHmZf0vM9wD4XGqzPKnTSqL1Pk="
            ]
        )
    ])

    return ZStack {
        Color.primaryBackground.ignoresSafeArea()
        PinsView(vm: PinsViewModel(repository: repository))
    }
    .preferredColorScheme(.light)
}
