//
//  CertificateFactory.swift
//  PinnedTests
//
//  Created by Michał Wolanin on 27/05/2026.
//

import Foundation
@testable import Pinned

/// Fixture builder for `Certificate` / `CertificateChain`, mirroring `PinSetFactory`.
/// Defaults are "valid and uninteresting" so each test overrides only what it asserts on.
enum CertificateFactory {

    static func certificate(
        subject: String = "cn",
        issuer: String = "issuer",
        keyType: KeyType = .ecdsaP256,
        spkiHash: String = "hash",
        notBefore: Date = .distantPast,
        notAfter: Date = .distantFuture
    ) -> Certificate {
        Certificate(
            subjectCommonName: subject,
            issuerCommonName: issuer,
            keyType: keyType,
            spkiHash: spkiHash,
            notBefore: notBefore,
            notAfter: notAfter
        )
    }

    /// Builds a chain whose certificates carry exactly the given SPKI hashes,
    /// in order (index 0 = leaf, last = root).
    static func chain(hashes: [String]) -> CertificateChain {
        CertificateChain(
            certificates: hashes.enumerated().map { index, hash in
                certificate(subject: "cn-\(index)", issuer: "issuer-\(index)", spkiHash: hash)
            }
        )
    }
}
