//
//  PinsUpsertViewModel.swift
//  Pinned
//
//  Created by Michał Wolanin on 22/05/2026.
//

import Foundation
import SwiftUI
import Observation

@Observable
@MainActor
public final class PinUpsertViewModel {
    public enum Mode: Equatable {
        case create
        case edit(PinSet)
    }

    private let mode: Mode

    public var domain: String
    public var includeSubdomains: Bool
    public private(set) var hashes: [String]
    public var draftHash: String = ""
    public private(set) var validationError: ValidationError?

    public enum ValidationError: Equatable {
        case invalidFormat
        case duplicate
    }

    public init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .create:
            self.domain = ""
            self.includeSubdomains = false
            self.hashes = []
        case .edit(let pinSet):
            self.domain = pinSet.domain
            self.includeSubdomains = pinSet.includeSubdomains
            self.hashes = pinSet.hashes
        }
    }

    // MARK: - Derived state
    public var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    public var canSave: Bool {
        !trimmedDomain.isEmpty && !hashes.isEmpty
    }

    public var canAddHash: Bool {
        !draftHash.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Hash management
    public func addHash() {
        let candidate = draftHash.trimmingCharacters(in: .whitespaces)

        guard isValidSPKIHash(candidate) else {
            validationError = .invalidFormat
            return
        }
        guard !hashes.contains(candidate) else {
            validationError = .duplicate
            return
        }

        hashes.append(candidate)
        draftHash = ""
        validationError = nil
    }

    public func removeHash(at offsets: IndexSet) {
        hashes.remove(atOffsets: offsets)
    }

    public func removeHash(_ hash: String) {
        hashes.removeAll { $0 == hash }
    }

    // MARK: - Build result
    public func buildPinSet() -> PinSet {
        switch mode {
        case .create:
            PinSet(
                domain: trimmedDomain,
                hashes: hashes,
                includeSubdomains: includeSubdomains
            )
        case .edit(let original):
            PinSet(
                id: original.id,
                domain: trimmedDomain,
                hashes: hashes,
                includeSubdomains: includeSubdomains,
                createdAt: original.createdAt
            )
        }
    }

    // MARK: - Helpers
    private var trimmedDomain: String {
        domain.trimmingCharacters(in: .whitespaces)
    }

    private func isValidSPKIHash(_ hash: String) -> Bool {
        guard hash.count == 44, hash.hasSuffix("=") else { return false }
        return Data(base64Encoded: hash) != nil
    }
}
