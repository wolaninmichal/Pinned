//
//  PinsVMTests.swift
//  PinnedTests
//
//  Created by Michał Wolanin on 26/05/2026.
//

import Testing
import Foundation
@testable import Pinned

@MainActor
@Suite("PinsViewModel – save orchestration")
struct PinsViewModelTests {

    // MARK: - happy path
    @Test("save adds the pin locally and dismisses the route")
    func save_appendsLocally_andDismissesRoute() async {
        let sut = PinsViewModel(repository: InMemoryPinRepository())
        sut.startCreating()
        #expect(sut.route != nil)

        let pin = PinSetFactory.make()
        await sut.save(pin)

        #expect(sut.pinSets == [pin])
        #expect(sut.route == nil)
    }

    @Test("save with an existing id updates the pin in place instead of duplicating")
    func save_updatesExistingInPlace() async {
        let pin = PinSetFactory.make()
        let sut = PinsViewModel(repository: InMemoryPinRepository(seed: [pin]))
        await sut.load()

        let edited = PinSetFactory.make(id: pin.id, domain: "api.changed.com", createdAt: pin.createdAt)
        await sut.save(edited)

        #expect(sut.pinSets == [edited])
    }

    @Test("load populates pins from the repository")
    func load_populatesFromRepository() async {
        let pins = PinSetFactory.makeSequence(count: 2)
        let sut = PinsViewModel(repository: InMemoryPinRepository(seed: pins))

        await sut.load()

        #expect(sut.pinSets == pins)
    }

    // MARK: - rollback on failure
    @Test("A save faure rolls back the optimistic change via reload")
    func save_failure_rollsBackViaReload() async {
        let sut = PinsViewModel(repository: InMemoryPinRepository(failureMode: .onSave))

        await sut.save(PinSetFactory.make())

        #expect(sut.pinSets.isEmpty)
    }

    @Test("A delete failure restores the previous state (snapshot)")
    func delete_failure_restoresSnapshot() async {
        let pin = PinSetFactory.make()
        let sut = PinsViewModel(repository: InMemoryPinRepository(seed: [pin], failureMode: .onDelete))
        await sut.load()

        await sut.delete(pin)

        #expect(sut.pinSets == [pin])
    }

    // MARK: - routing
    @Test("startEditing sets the route to edit the given pin")
    func startEditing_setsEditRoute() async {
        let pin = PinSetFactory.make()
        let sut = PinsViewModel(repository: InMemoryPinRepository())

        sut.startEditing(pin)

        #expect(sut.route == .edit(pin))
    }

    @Test("dismissRoute clears the route")
    func dismissRoute_clearsRoute() async {
        let sut = PinsViewModel(repository: InMemoryPinRepository())
        sut.startCreating()

        sut.dismissRoute()

        #expect(sut.route == nil)
    }
}
