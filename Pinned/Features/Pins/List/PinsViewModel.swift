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

    private let repository: PinRepository

    public init(repository: PinRepository) {
        self.repository = repository
    }

    // MARK: - Lifecycle
    public func load() async {
        do {
            pinSets = try await repository.fetchAll()
        } catch {
            /// todo
        }
    }

    // MARK: - Routing intents

    public func startCreating() { route = .create }
    public func startEditing(_ pinSet: PinSet) { route = .edit(pinSet) }
    public func dismissRoute() { route = nil }

    // MARK: - Mutations
    public func save(_ pinSet: PinSet) async {
        applyLocally(pinSet)
        route = nil
        do {
            try await repository.save(pinSet)
        } catch {
            await load()
        }
    }

    public func delete(_ pinSet: PinSet) async {
        let snapshot = pinSets
        pinSets.removeAll { $0.id == pinSet.id }
        do {
            try await repository.delete(id: pinSet.id)
        } catch {
            pinSets = snapshot
        }
    }

    // MARK: - Helpers
    private func applyLocally(_ pinSet: PinSet) {
        if let index = pinSets.firstIndex(where: { $0.id == pinSet.id }) {
            pinSets[index] = pinSet
        } else {
            pinSets.append(pinSet)
        }
        pinSets.sort { $0.createdAt < $1.createdAt }
    }
}
