//
//  PinSetEntity+Mapping.swift
//  Pinned
//
//  Created by Michał Wolanin on 25/05/2026.
//

import CoreData

extension PinSetEntity {
    /// entity -> domain
    func toDomain() throws -> PinSet {
        let hashes: [String]
        do {
            hashes = try JSONDecoder().decode([String].self, from: hashesData)
        } catch {
            throw RepositoryError.decodingFailed(id: id, underlying: error)
        }

        return PinSet(
            id: id,
            domain: domain,
            hashes: hashes,
            includeSubdomains: includeSubdomains,
            createdAt: createdAt
        )
    }

    /// domain -> entity
    func apply(_ pinSet: PinSet) throws {
        id = pinSet.id
        domain = pinSet.domain
        includeSubdomains = pinSet.includeSubdomains
        createdAt = pinSet.createdAt
        do {
            hashesData = try JSONEncoder().encode(pinSet.hashes)
        } catch {
            throw RepositoryError.encodingFailed(id: pinSet.id, underlying: error)
        }
    }
}
