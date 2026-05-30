//
//  InMemoryPinRepositoryTests.swift
//  PinnedTests
//
//  Created by Michał Wolanin on 26/05/2026.
//

import Testing
import Foundation
@testable import Pinned

@Suite("InMemoryPinRepository – test double")
struct InMemoryPinRepositoryTests {

    // MARK: - Contract-compliant behaviour
    @Test("Seed is returned sorted scending by createdAt")
    func seed_returnedSortedByCreatedAt() async throws {
        let pins = PinSetFactory.makeSequence(count: 3)
        let sut = await InMemoryPinRepository(seed: pins.shuffled())

        #expect(try await sut.fetchAll() == pins)
    }

    @Test("save appends a new pin")
    func save_appendsPin() async throws {
        let sut = await InMemoryPinRepository()
        let pin = PinSetFactory.make()

        try await sut.save(pin)

        #expect(try await sut.fetchAll() == [pin])
    }

    @Test("save with an existing id overwrites the entry")
    func save_overwritesById() async throws {
        let pin = PinSetFactory.make()
        let sut = await InMemoryPinRepository(seed: [pin])

        let edited = await PinSetFactory.make(id: pin.id, domain: "api.changed.com", createdAt: pin.createdAt)
        try await sut.save(edited)

        #expect(try await sut.fetchAll() == [edited])
    }

    @Test("delete removes the entry by id")
    func delete_removesById() async throws {
        let pin = PinSetFactory.make()
        let sut = await InMemoryPinRepository(seed: [pin])

        try await sut.delete(id: pin.id)

        #expect(try await sut.fetchAll().isEmpty)
    }

    // MARK: - Failure injection

    @Test("failureMode .onFetch throws a RepositoryError")
    func failureMode_onFetch_throws() async {
        let sut = await InMemoryPinRepository(failureMode: .onFetch)
        await #expect(throws: RepositoryError.self) {
            _ = try await sut.fetchAll()
        }
    }

    @Test("failureMode .onSave throws and does not mutate state")
    func failureMode_onSave_throwsAndDoesNotMutate() async throws {
        let sut = await InMemoryPinRepository(failureMode: .onSave)

        await #expect(throws: RepositoryError.self) {
            try await sut.save(PinSetFactory.make())
        }
        #expect(try await sut.fetchAll().isEmpty)
    }

    @Test("failureMode .onDelete throws a RepositoryError")
    func failureMode_onDelete_throws() async {
        let sut = await InMemoryPinRepository(failureMode: .onDelete)
        await #expect(throws: RepositoryError.self) {
            try await sut.delete(id: UUID())
        }
    }
}
