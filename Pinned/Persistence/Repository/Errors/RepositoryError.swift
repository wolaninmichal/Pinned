//
//  RepositoryError.swift
//  Pinned
//
//  Created by Michał Wolanin on 25/05/2026.
//

import Foundation

public enum RepositoryError: Error {
    case fetchFailed(underlying: Error)
    case saveFailed(underlying: Error)
    case deleteFailed(underlying: Error)

    case decodingFailed(id: UUID, underlying: Error)
    case encodingFailed(id: UUID, underlying: Error)
}

// MARK: - LocalizedError
extension RepositoryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .fetchFailed(let error):
            "Nie udało się pobrać pinów: \(error.localizedDescription)"
        case .saveFailed(let error):
            "Nie udało się zapisać pinu: \(error.localizedDescription)"
        case .deleteFailed(let error):
            "Nie udało się usunąć pinu: \(error.localizedDescription)"
        case .decodingFailed(let id, let error):
            "Uszkodzone dane pinu \(id): \(error.localizedDescription)"
        case .encodingFailed(let id, let error):
            "Nie udało się zserializować pinu \(id): \(error.localizedDescription)"
        }
    }
}
