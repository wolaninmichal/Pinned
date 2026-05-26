//
//  PinSetEntityMappingTests.swift
//  PinnedTests
//
//  Created by Michał Wolanin on 26/05/2026.
//

import Testing
import Foundation
import CoreData
@testable import Pinned

@Suite("PinSetEntity != PinSet – mapping")
struct PinSetEntityMappingTests {

    let context: NSManagedObjectContext

    init() {
        context = CoreDataTestStack.mContext()
    }

    // MARK: - Round-trip

    @Test("apply → toDomain is a faithful round-trip of all fields")
    func roundTrip_preservesAllFields() throws {
        let pin = PinSetFactory.make(
            hashes: [PinSetFactory.validHashA, PinSetFactory.validHashB],
            includeSubdomains: true
        )
        let entity = PinSetEntity(context: context)

        try entity.apply(pin)
        let result = try entity.toDomain()

        #expect(result == pin)
    }

    @Test("An empty hash list round-trips correctly")
    func roundTrip_emptyHashes() throws {
        let pin = PinSetFactory.make(hashes: [])
        let entity = PinSetEntity(context: context)

        try entity.apply(pin)

        #expect(try entity.toDomain().hashes.isEmpty)
    }

    // MARK: - Corrupted data

    @Test("Corrupted hashesData throws RepositoryError.decodingFailed carrying the correct id")
    func toDomain_corruptedHashes_throwsDecodingFailed() throws {
        let id = UUID()
        let entity = PinSetEntity(context: context)
        entity.id = id
        entity.domain = "api.example.com"
        entity.includeSubdomains = false
        entity.createdAt = PinSetFactory.referenceDate
        entity.hashesData = Data("definitely-not-json".utf8)

        do {
            _ = try entity.toDomain()
            Issue.record("Expected an error to be thrown, but toDomain() succeeded")
        } catch let error as RepositoryError {
            guard case .decodingFailed(let failedID, _) = error else {
                Issue.record("Wrong error case: \(error)")
                return
            }
            #expect(failedID == id)
        }
    }
}
