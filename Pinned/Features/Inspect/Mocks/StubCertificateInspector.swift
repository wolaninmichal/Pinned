//
//  StubCertificateInspector.swift
//  Pinned
//
//  Created by Michał Wolanin on 26/05/2026.
//

import Foundation

public struct StubCertificateInspector: CertificateInspector {

    public enum Outcome: Sendable {
        case success(CertificateChain)
        case failure(InspectionError)
    }

    private let outcome: Outcome
    private let delay: Duration

    public init(outcome: Outcome, delay: Duration = .milliseconds(600)) {
        self.outcome = outcome
        self.delay = delay
    }

    public func inspect(url: URL) async throws -> CertificateChain {
        Log.debug("StubCertificateInspector: simulating inspection of \(url.absoluteString)")
        try? await Task.sleep(for: delay)
        switch outcome {
        case .success(let chain): return chain
        case .failure(let error): throw error
        }
    }
}

// MARK: - Sample data
public extension StubCertificateInspector {

    static let sampleChain = CertificateChain(certificates: [
        Certificate(
            subjectCommonName: "api.example.com",
            issuerCommonName: "GTS CA 1P5",
            keyType: .ecdsaP256,
            spkiHash: "r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E=",
            notBefore: Date().addingTimeInterval(-86_400 * 30),
            notAfter: Date().addingTimeInterval(86_400 * 60)
        ),
        Certificate(
            subjectCommonName: "GTS CA 1P5",
            issuerCommonName: "GTS Root R1",
            keyType: .rsa2048,
            spkiHash: "YZPgTZ+woNCCCIW3LH2CxQeLzB/0pxKj2KkmF5pj9rE=",
            notBefore: Date().addingTimeInterval(-86_400 * 1000),
            notAfter: Date().addingTimeInterval(86_400 * 1500)
        )
    ])

    static var succeeding: StubCertificateInspector {
        .init(outcome: .success(sampleChain))
    }

    static var failing: StubCertificateInspector {
        .init(outcome: .failure(.standardValidationFailed))
    }
}
