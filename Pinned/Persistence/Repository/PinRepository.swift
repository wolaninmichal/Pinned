//
//  PinRepository.swift
//  Pinned
//
//  Created by Michał Wolanin on 25/05/2026.
//

import Foundation

public protocol PinRepository: Sendable {
    func fetchAll() async throws -> [PinSet]
    func save(_ pinSet: PinSet) async throws
    func delete(id: UUID) async throws
}
