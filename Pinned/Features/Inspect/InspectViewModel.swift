//
//  InspectViewModel.swift
//  Pinned
//
//  Created by Michał Wolanin on 20/05/2026.
//

import Foundation
import Observation

@Observable
@MainActor
public final class InspectViewModel {
    public enum State: Equatable {
        case idle
        case loading
        case results(chain: CertificateChain, match: MatchResult)
        case failed(InspectionError)
    }

    public var urlText: String = ""
    public private(set) var state: State = .idle

    public init() {}

    public func inspect() async {
        guard !urlText.trimmingCharacters(in: .whitespaces).isEmpty else {
            state = .failed(.invalidURL)
            return
        }

        state = .loading
        try? await Task.sleep(for: .milliseconds(900))
        
        /// TEMP
        if urlText.contains("error") {
            state = .failed(.standardValidationFailed)
        } else if urlText.contains("mismatch") {
            state = .results(chain: Self.sampleChain, match: .mismatch)
        } else {
            state = .results(chain: Self.sampleChain, match: .matched(level: .intermediate(index: 1)))
        }
    }

    public func reset() {
        state = .idle
        urlText = ""
    }

    /// TEMP
    private static let sampleChain = CertificateChain(certificates: [
        Certificate(
            subjectCommonName: "api.example.com",
            issuerCommonName: "GTS CA 1P5",
            keyType: .ecdsaP256,
            spkiHash: "r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E=",
            notBefore: Date().addingTimeInterval(-86400 * 30),
            notAfter: Date().addingTimeInterval(86400 * 60)
        ),
        Certificate(
            subjectCommonName: "GTS CA 1P5",
            issuerCommonName: "GTS Root R1",
            keyType: .rsa2048,
            spkiHash: "YZPgTZ+woNCCCIW3LH2CxQeLzB/0pxKj2KkmF5pj9rE=",
            notBefore: Date().addingTimeInterval(-86400 * 1000),
            notAfter: Date().addingTimeInterval(86400 * 1500)
        )
    ])
}
