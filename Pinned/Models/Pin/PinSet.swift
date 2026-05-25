//
//  PinSet.swift
//  Pinned
//
//  Created by Michał Wolanin on 22/05/2026.
//

import Foundation

public struct PinSet: Identifiable, Sendable, Equatable, Hashable {
    public let id: UUID
    public let domain: String
    public let hashes: [String]
    public let includeSubdomains: Bool
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        domain: String,
        hashes: [String],
        includeSubdomains: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.domain = domain
        self.hashes = hashes
        self.includeSubdomains = includeSubdomains
        self.createdAt = createdAt
    }
}
