//
//  InspectVMTests.swift
//  PinnedTests
//
//  Created by Michał Wolanin on 27/05/2026.
//

import Testing
@testable import Pinned

@Suite("InspectViewModel")
@MainActor
struct InspectVMTests {

    // First certificate of sampleChain carries this hash — used for matching pins.
    private let sampleLeafHash = "r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E="

    private func makeSUT(
        inspector: CertificateInspector,
        seed: [PinSet] = [],
        failureMode: InMemoryPinRepository.FailureMode = .none
    ) -> InspectViewModel {
        InspectViewModel(
            inspector: inspector,
            pinRepository: InMemoryPinRepository(seed: seed, failureMode: failureMode)
        )
    }

    private func succeeding(_ chain: CertificateChain) -> StubCertificateInspector {
        StubCertificateInspector(outcome: .success(chain), delay: .zero)
    }

    @Test("Empty URL fails with .invalidURL without touching the inspector")
    func emptyURLFails() async {
        let sut = makeSUT(inspector: succeeding(.init(certificates: [])))
        sut.urlText = "   "

        await sut.inspect()

        #expect(sut.state == .failed(.invalidURL))
    }

    @Test("Success without pins yields results + noPinsForDomain")
    func successWithoutPins() async {
        let sut = makeSUT(inspector: succeeding(StubCertificateInspector.sampleChain))
        sut.urlText = "api.example.com"

        await sut.inspect()

        #expect(sut.state == .results(
            chain: StubCertificateInspector.sampleChain,
            match: .noPinsForDomain
        ))
    }

    @Test("Success with a matching pin yields matched(.leaf)")
    func successWithMatchingPin() async {
        let sut = makeSUT(
            inspector: succeeding(StubCertificateInspector.sampleChain),
            seed: [PinSetFactory.make(domain: "api.example.com", hashes: [sampleLeafHash])]
        )
        sut.urlText = "api.example.com"

        await sut.inspect()

        #expect(sut.state == .results(
            chain: StubCertificateInspector.sampleChain,
            match: .matched(level: .leaf)
        ))
    }

    @Test("A full URL with scheme and path is accepted")
    func acceptsFullURL() async {
        let sut = makeSUT(inspector: succeeding(StubCertificateInspector.sampleChain))
        sut.urlText = "https://api.example.com/v1/health"

        await sut.inspect()

        if case .results = sut.state {} else {
            Issue.record("Expected .results, got \(sut.state)")
        }
    }

    @Test("An inspection error propagates to .failed unchanged")
    func inspectionErrorPropagates() async {
        let sut = makeSUT(
            inspector: StubCertificateInspector(outcome: .failure(.standardValidationFailed), delay: .zero)
        )
        sut.urlText = "api.example.com"

        await sut.inspect()

        #expect(sut.state == .failed(.standardValidationFailed))
    }

    @Test("A repository failure is non-fatal: the chain is still shown")
    func repositoryFailureIsNonFatal() async {
        let sut = makeSUT(
            inspector: succeeding(StubCertificateInspector.sampleChain),
            failureMode: .onFetch
        )
        sut.urlText = "api.example.com"

        await sut.inspect()

        // Despite the fetchAll failure we get results (no verdict), NOT .failed.
        #expect(sut.state == .results(
            chain: StubCertificateInspector.sampleChain,
            match: .noPinsForDomain
        ))
    }

    @Test("reset() clears both state and the URL field")
    func resetClearsEverything() async {
        let sut = makeSUT(inspector: succeeding(StubCertificateInspector.sampleChain))
        sut.urlText = "api.example.com"
        await sut.inspect()

        sut.reset()

        #expect(sut.state == .idle)
        #expect(sut.urlText.isEmpty)
    }
}
