//
//  PinsViewModel.swift
//  Pinned
//
//  Created by Michał Wolanin on 20/05/2026.
//

import Foundation
import Observation

@Observable
@MainActor
public final class PinsViewModel {

    public private(set) var pinSets: [PinSet] = []
    public var route: PinsRoute?

    public init() {}

    // MARK: - Routing intents
    public func startCreating() {
        route = .create
    }

    public func startEditing(_ pinSet: PinSet) {
        route = .edit(pinSet)
    }

    public func dismissRoute() {
        route = nil
    }

    // MARK: - Mutations
    public func save(_ pinSet: PinSet) {
        if let index = pinSets.firstIndex(where: { $0.id == pinSet.id }) {
            pinSets[index] = pinSet
        } else {
            pinSets.append(pinSet)
        }
        route = nil
    }

    public func delete(_ pinSet: PinSet) {
        pinSets.removeAll { $0.id == pinSet.id }
    }
}
