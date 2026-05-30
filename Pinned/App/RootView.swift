//
//  RootView.swift
//  Pinned
//
//  Created by Michał Wolanin on 15/05/2026.
//

import SwiftUI

public struct RootView: View {
    let inspectViewModel: InspectViewModel
    let pinsViewModel: PinsViewModel

    @State private var selectedTab: TabBarChrome.Tab = .inspect

    init(
        inspectViewModel: InspectViewModel,
        pinsViewModel: PinsViewModel
    ) {
        self.inspectViewModel = inspectViewModel
        self.pinsViewModel = pinsViewModel
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            Color.primaryBackground.ignoresSafeArea()

            Group {
                switch selectedTab {
                case .inspect:
                    InspectView(vm: inspectViewModel)
                case .pins:
                    PinsView(vm: pinsViewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)

            TabBarChrome(selection: $selectedTab)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
        }
        .preferredColorScheme(.light)
    }
}

#Preview("Root View") {
    let repository = InMemoryPinRepository()
    return RootView(
        inspectViewModel: InspectViewModel(
            inspector: StubCertificateInspector.succeeding,
            pinRepository: repository
        ),
        pinsViewModel: PinsViewModel(repository: repository)
    )
}
