//
//  PinSetFactory.swift
//  PinnedTests
//
//  Created by Michał Wolanin on 26/05/2026.
//

import Foundation
@testable import Pinned

enum PinSetFactory {

    /// correct hashes, 44 signs, decodabled to data
    static let validHashA = "r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E="
    static let validHashB = "YZPgTZ+woNCCCIW3LH2CxQeLzB/0pxKj2KkmF5pj9rE="
    static let validHashC = "x/Q42aFnL5LBjQQqYxHmZf0vM9wD4XGqzPKnTSqL1Pk="

    /// stable timebase to avoid flickering of order-dependent tests
    static let referenceDate = Date(timeIntervalSince1970: 1_700_000_000)

    static func make(
        id: UUID = UUID(),
        domain: String = "api.example.com",
        hashes: [String] = [PinSetFactory.validHashA],
        includeSubdomains: Bool = false,
        createdAt: Date = PinSetFactory.referenceDate
    ) -> PinSet {
        PinSet(
            id: id,
            domain: domain,
            hashes: hashes,
            includeSubdomains: includeSubdomains,
            createdAt: createdAt
        )
    }

    /// convenient helper for sorting scenarios: n pins with increasing `createdAt`
    static func makeSequence(count: Int) -> [PinSet] {
        (0..<count).map { offset in
            make(
                id: UUID(),
                domain: "host-\(offset).example.com",
                createdAt: referenceDate.addingTimeInterval(TimeInterval(offset))
            )
        }
    }
}
