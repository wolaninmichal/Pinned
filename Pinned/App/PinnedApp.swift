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
        self.inspectViewModel = InspectViewModel()
        self.pinsViewModel = PinsViewModel()
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
