//
//  InMemoryPinRepository.swift
//  Pinned
//
//  Created by Michał Wolanin on 25/05/2026.
//

import Foundation

public actor InMemoryPinRepository: PinRepository {
    public enum FailureMode: Sendable {
        case none
        case onFetch
        case onSave
        case onDelete
    }

    private var storage: [UUID: PinSet]
    private let failureMode: FailureMode

    public init(seed: [PinSet] = [], failureMode: FailureMode = .none) {
        self.storage = Dictionary(uniqueKeysWithValues: seed.map { ($0.id, $0) })
        self.failureMode = failureMode
    }

    // MARK: - PinRepository
    public func fetchAll() async throws -> [PinSet] {
        if case .onFetch = failureMode {
            throw RepositoryError.fetchFailed(underlying: MockError.injected)
        }
        return storage.values.sorted { $0.createdAt < $1.createdAt }
    }

    public func save(_ pinSet: PinSet) async throws {
        if case .onSave = failureMode {
            throw RepositoryError.saveFailed(underlying: MockError.injected)
        }
        storage[pinSet.id] = pinSet
    }

    public func delete(id: UUID) async throws {
        if case .onDelete = failureMode {
            throw RepositoryError.deleteFailed(underlying: MockError.injected)
        }
        storage[id] = nil
    }

    // MARK: - Test helper
    private enum MockError: Error { case injected }
}
