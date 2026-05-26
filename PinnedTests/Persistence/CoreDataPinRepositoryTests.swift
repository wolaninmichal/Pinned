//
//  CoreDataPinRepositoryTests.swift
//  PinnedTests
//
//  Created by Michał Wolanin on 26/05/2026.
//

import Testing
import Foundation
@testable import Pinned

@Suite("CoreDataPinRepository – save logic")
struct CoreDataPinRepositoryTests {

    let sut: CoreDataPinRepository

    init() {
        sut = CoreDataTestStack.mRepository()
    }

    // MARK: - save → fetch (round-trip)
    @Test("a saved pin is returned by fetchAll with all fields preserved")
    func save_thenFetchAll_returnsIdenticalPin() async throws {
        let pin = PinSetFactory.make(
            hashes: [PinSetFactory.validHashA, PinSetFactory.validHashB],
            includeSubdomains: true
        )

        try await sut.save(pin)
        let all = try await sut.fetchAll()

        #expect(all == [pin])
    }

    @Test("hash order is preserved after a save")
    func save_preservesHashOrder() async throws {
        let pin = PinSetFactory.make(hashes: [
            PinSetFactory.validHashA,
            PinSetFactory.validHashB,
            PinSetFactory.validHashC
        ])

        try await sut.save(pin)

        #expect(try await sut.fetchAll().first?.hashes == pin.hashes)
    }

    @Test("the includeSubdomains flag is persisted")
    func save_persistsIncludeSubdomains() async throws {
        try await sut.save(PinSetFactory.make(includeSubdomains: true))
        #expect(try await sut.fetchAll().first?.includeSubdomains == true)
    }

    // MARK: - upsert (by id)
    @Test("saving again with the same id updates the entity instead of duplicating")
    func save_withSameId_updatesInPlace() async throws {
        let id = UUID()
        let original = PinSetFactory.make(id: id, domain: "api.example.com")
        try await sut.save(original)

        let updated = await PinSetFactory.make(
            id: id,
            domain: "api.changed.com",
            hashes: [PinSetFactory.validHashA, PinSetFactory.validHashB],
            includeSubdomains: true,
            createdAt: original.createdAt
        )
        try await sut.save(updated)

        let all = try await sut.fetchAll()
        #expect(all.count == 1)
        #expect(all.first == updated)
    }

    @Test("saving the same pin twice is idempotent")
    func save_twice_isIdempotent() async throws {
        let pin = PinSetFactory.make()

        try await sut.save(pin)
        try await sut.save(pin)

        #expect(try await sut.fetchAll().count == 1)
    }

    // MARK: - multiple pins / sorting
    @Test("saving multiple distinct pins keeps them all")
    func save_multipleDistinctPins() async throws {
        let pins = PinSetFactory.makeSequence(count: 3)

        for pin in pins { try await sut.save(pin) }

        #expect(try await sut.fetchAll() == pins)
    }

    @Test("fetchAll sorts ascending by createdAt regardless of save order")
    func fetchAll_isSortedByCreatedAt() async throws {
        let older = PinSetFactory.make(
            id: UUID(), domain: "a.com",
            createdAt: PinSetFactory.referenceDate
        )
        let newer = PinSetFactory.make(
            id: UUID(), domain: "b.com",
            createdAt: PinSetFactory.referenceDate.addingTimeInterval(60)
        )

        try await sut.save(newer)
        try await sut.save(older)

        #expect(try await sut.fetchAll().map(\.id) == [older.id, newer.id])
    }

    // MARK: - dlete
    @Test("deleting by id removes the entry")
    func delete_removesPin() async throws {
        let pin = PinSetFactory.make()
        try await sut.save(pin)

        try await sut.delete(id: pin.id)

        #expect(try await sut.fetchAll().isEmpty)
    }

    @Test("deleting an unknown id neither throws nor touches the remaining entries")
    func delete_unknownId_isNoOp() async throws {
        let pin = PinSetFactory.make()
        try await sut.save(pin)

        try await sut.delete(id: UUID())

        #expect(try await sut.fetchAll() == [pin])
    }

    @Test("deleting one pin does not affect the others")
    func delete_onlyRemovesTargetedPin() async throws {
        let pins = PinSetFactory.makeSequence(count: 3)
        for pin in pins { try await sut.save(pin) }

        try await sut.delete(id: pins[1].id)

        #expect(try await sut.fetchAll().map(\.id) == [pins[0].id, pins[2].id])
    }

    // MARK: - initial state
    @Test("an empty store returns an empty list")
    func fetchAll_emptyStore_returnsEmpty() async throws {
        #expect(try await sut.fetchAll().isEmpty)
    }
}
