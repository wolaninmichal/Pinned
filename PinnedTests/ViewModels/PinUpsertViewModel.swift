//
//  PinUpsertViewModel.swift
//  PinnedTests
//
//  Created by Michał Wolanin on 27/05/2026.
//

import Testing
import Foundation
@testable import Pinned

@Suite("PinUpsertViewModel")
@MainActor
struct PinUpsertVMTests {
    
    private let validHash  = "r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E="
    private let validHash2 = "YZPgTZ+woNCCCIW3LH2CxQeLzB/0pxKj2KkmF5pj9rE="

    @Test("Create mode starts empty")
    func createStartsEmpty() {
        let sut = PinUpsertViewModel(mode: .create)
        #expect(sut.domain.isEmpty)
        #expect(sut.hashes.isEmpty)
        #expect(sut.includeSubdomains == false)
        #expect(sut.isEditing == false)
        #expect(sut.canSave == false)
    }

    @Test("Edit mode hydrates fields from the PinSet")
    func editHydratesFromPinSet() {
        let pinSet = PinSetFactory.make(
            domain: "api.example.com",
            hashes: [validHash],
            includeSubdomains: true
        )
        let sut = PinUpsertViewModel(mode: .edit(pinSet))

        #expect(sut.domain == "api.example.com")
        #expect(sut.hashes == [validHash])
        #expect(sut.includeSubdomains)
        #expect(sut.isEditing)
    }

    // MARK: - Hash validation
    @Test("Adding a valid hash clears the draft and the error")
    func addValidHash() {
        let sut = PinUpsertViewModel(mode: .create)
        sut.draftHash = validHash

        sut.addHash()

        #expect(sut.hashes == [validHash])
        #expect(sut.draftHash.isEmpty)
        #expect(sut.validationError == nil)
    }

    @Test("Invalid format is rejected with .invalidFormat", arguments: [
        "tooShort",
        "no-trailing-equals-padding-here-aaaaaaaaaaa",
        "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!=", /// 44 chars, not base64
    ])
    func invalidFormatRejected(candidate: String) {
        let sut = PinUpsertViewModel(mode: .create)
        sut.draftHash = candidate

        sut.addHash()

        #expect(sut.hashes.isEmpty)
        #expect(sut.validationError == .invalidFormat)
    }

    @Test("A duplicate hash is rejected with .duplicate")
    func duplicateRejected() {
        let sut = PinUpsertViewModel(mode: .create)
        sut.draftHash = validHash
        sut.addHash()

        sut.draftHash = validHash
        sut.addHash()

        #expect(sut.hashes == [validHash])
        #expect(sut.validationError == .duplicate)
    }

    @Test("canAddHash is false for an empty or whitespace draft")
    func canAddHashGating() {
        let sut = PinUpsertViewModel(mode: .create)
        #expect(sut.canAddHash == false)
        sut.draftHash = "   "
        #expect(sut.canAddHash == false)
        sut.draftHash = "anything"
        #expect(sut.canAddHash)
    }

    @Test("removeHash removes by value")
    func removeHashByValue() {
        let sut = PinUpsertViewModel(mode: .create)
        sut.draftHash = validHash;  sut.addHash()
        sut.draftHash = validHash2; sut.addHash()

        sut.removeHash(validHash)

        #expect(sut.hashes == [validHash2])
    }

    // MARK: - canSave

    @Test("canSave requires a domain AND at least one hash")
    func canSaveRequiresBoth() {
        let sut = PinUpsertViewModel(mode: .create)
        #expect(sut.canSave == false)

        sut.domain = "api.example.com"
        #expect(sut.canSave == false) /// no hashes yet

        sut.draftHash = validHash; sut.addHash()
        #expect(sut.canSave)
    }

    // MARK: - buildPinSet

    @Test("buildPinSet trims the domain in create mode")
    func buildTrimsDomain() {
        let sut = PinUpsertViewModel(mode: .create)
        sut.domain = "   api.example.com   "
        sut.draftHash = validHash; sut.addHash()

        let result = sut.buildPinSet()

        #expect(result.domain == "api.example.com")
    }

    @Test("buildPinSet preserves id and createdAt in edit mode")
    func buildPreservesIdentityOnEdit() {
        let original = PinSetFactory.make(
            domain: "api.example.com",
            hashes: [validHash],
            includeSubdomains: false,
            createdAt: Date(timeIntervalSince1970: 1_000)
        )
        let sut = PinUpsertViewModel(mode: .edit(original))
        sut.domain = "new.example.com"

        let result = sut.buildPinSet()

        #expect(result.id == original.id)
        #expect(result.createdAt == original.createdAt)
        #expect(result.domain == "new.example.com")
    }
}
