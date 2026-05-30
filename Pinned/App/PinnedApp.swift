//
//  PinnedApp.swift
//  Pinned
//
//  Created by Michał Wolanin on 12/05/2026.
//

import SwiftUI

@main
struct PinnedApp: App {

    private let inspectViewModel: InspectViewModel
    private let pinsViewModel: PinsViewModel

    init() {
        #if DEBUG
        Log.setLogTypes([.info, .debug, .warning, .error, .initObj, .deinitObj, .database])
        #endif

        let store: PinStore = .init()
        let pinRepository: PinRepository = CoreDataPinRepository(store: store)

        self.inspectViewModel = .init(pinRepository: pinRepository)
        self.pinsViewModel = .init(repository: pinRepository)
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                inspectViewModel: inspectViewModel,
                pinsViewModel: pinsViewModel
            )
        }
    }
}
