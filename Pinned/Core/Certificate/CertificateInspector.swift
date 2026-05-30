//
//  CertificateInspector.swift
//  Pinned
//
//  Created by Michał Wolanin on 26/05/2026.
//

import Foundation

/// Abstraction over "connect to a host and return its certificate chain".
///
/// Injected into `InspectViewModel`, which lets the view model be tested against a
/// `StubCertificateInspector` with zero networking — the production graph and the
/// test graph are wired identically.
public protocol CertificateInspector: Sendable {
    func inspect(url: URL) async throws -> CertificateChain
}
