//
//  InspectView.swift
//  Pinned
//
//  Created by Michał Wolanin on 15/05/2026.
//

import SwiftUI

struct InspectView: View {
    @Bindable var vm: InspectViewModel

    init(vm: InspectViewModel) {
        self.vm = vm
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                        .padding(.top, 26)
                        .padding(.bottom, 18)

                    URLInputField(text: $vm.urlText, isLoading: isLoading) {
                        Task { await vm.inspect() }
                    }
                    .padding(.bottom, 22)

                    content
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
                .frame(minHeight: proxy.size.height, alignment: .top)
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: vm.state)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

// MARK: - Subviews
private extension InspectView {

    var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(.Inspect.eyebrow)
                .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.55)))
                .tracking(1.2)
            Text(.Inspect.title)
                .plexStyle(.pinnedTitle.with(color: .primaryText))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    var content: some View {
        switch vm.state {
        case .idle:
            placeholder

        case .loading:
            loadingIndicator

        case .results(let chain, let match):
            VStack(spacing: 14) {
                CertificateChainView(chain: chain)
                MatchStatusBanner(result: match)
            }
            .transition(.opacity.combined(with: .move(edge: .bottom)))

        case .failed(let error):
            errorCard(for: error)
        }
    }

    var placeholder: some View {
        VStack(spacing: 10) {
            Image(systemName: "scope")
                .font(.system(size: 26))
                .foregroundStyle(Color.primaryText.opacity(0.4))
            Text(.Inspect.placeholder)
                .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.55)))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var loadingIndicator: some View {
        HStack {
            Spacer()
            ProgressView()
                .tint(Color.primaryText)
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }

    func errorCard(for error: InspectionError) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(.Inspect.errorTitle)
                .plexStyle(.pinnedBody.with(color: .primaryText))
            Text(message(for: error))
                .plexStyle(.pinnedCaption.with(color: .primaryText.opacity(0.75)))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.matchFailure.opacity(0.18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.matchFailure.opacity(0.45), lineWidth: 0.5)
        )
    }
}

// MARK: - Helpers
private extension InspectView {

    var isLoading: Bool {
        if case .loading = vm.state { return true }
        return false
    }

    func message(for error: InspectionError) -> LocalizedStringResource {
        switch error {
        case .invalidURL: .Inspect.invalidURL
        case .tlsHandshakeFailed(let m): .Inspect.tlsHandshake(m)
        case .standardValidationFailed: .Inspect.standardValidation
        case .emptyChain: .Inspect.emptyChain
        case .hashingFailed: .Inspect.hashingFailed
        }
    }
}

#Preview("Inspect View") {
    ZStack {
        Color.primaryBackground.ignoresSafeArea()
        InspectView(vm: InspectViewModel())
    }
    .preferredColorScheme(.light)
}
