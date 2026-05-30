//
//  PinMatcherTests.swift
//  PinnedTests
//
//  Created by Michał Wolanin on 27/05/2026.
//

import Testing
import Foundation
@testable import Pinned

@Suite("PinMatcher")
struct PinMatcherTests {

    private let sut = PinMatcher()

    // MARK: - Domain resolution

    @Test("Exact host match takes precedence")
    func exactMatch() {
        let result = sut.match(
            chain: CertificateFactory.chain(hashes: ["LEAF", "ROOT"]),
            host: "api.example.com",
            pinSets: [PinSetFactory.make(domain: "api.example.com", hashes: ["LEAF"])]
        )
        #expect(result == .matched(level: .leaf))
    }

    @Test("Host matching is case-insensitive")
    func caseInsensitiveHost() {
        let result = sut.match(
            chain: CertificateFactory.chain(hashes: ["LEAF"]),
            host: "API.Example.COM",
            pinSets: [PinSetFactory.make(domain: "api.example.com", hashes: ["LEAF"])]
        )
        #expect(result == .matched(level: .leaf))
    }

    @Test("Subdomain matches a parent pin when includeSubdomains is true")
    func subdomainMatch() {
        let result = sut.match(
            chain: CertificateFactory.chain(hashes: ["LEAF"]),
            host: "auth.example.com",
            pinSets: [PinSetFactory.make(domain: "example.com", hashes: ["LEAF"], includeSubdomains: true)]
        )
        #expect(result == .matched(level: .leaf))
    }

    @Test("Subdomain does NOT match when includeSubdomains is false")
    func subdomainIgnoredWithoutFlag() {
        let result = sut.match(
            chain: CertificateFactory.chain(hashes: ["LEAF"]),
            host: "auth.example.com",
            pinSets: [PinSetFactory.make(domain: "example.com", hashes: ["LEAF"], includeSubdomains: false)]
        )
        #expect(result == .noPinsForDomain)
    }

    @Test("No pin for the host yields noPinsForDomain")
    func noPinForHost() {
        let result = sut.match(
            chain: CertificateFactory.chain(hashes: ["LEAF"]),
            host: "other.com",
            pinSets: [PinSetFactory.make(domain: "example.com", hashes: ["LEAF"])]
        )
        #expect(result == .noPinsForDomain)
    }

    @Test("A pin with an empty hash list is treated as no pin")
    func emptyHashesTreatedAsNoPin() {
        let result = sut.match(
            chain: CertificateFactory.chain(hashes: ["LEAF"]),
            host: "example.com",
            pinSets: [PinSetFactory.make(domain: "example.com", hashes: [])]
        )
        #expect(result == .noPinsForDomain)
    }

    // MARK: - Hash matching

    @Test("No hash matches any certificate yields mismatch")
    func mismatch() {
        let result = sut.match(
            chain: CertificateFactory.chain(hashes: ["LEAF", "ROOT"]),
            host: "example.com",
            pinSets: [PinSetFactory.make(domain: "example.com", hashes: ["UNRELATED"])]
        )
        #expect(result == .mismatch)
    }

    @Test("Match reports the position of the matched certificate", arguments: [
        (["A", "B", "C"], "A", CertificateChain.Position.leaf),
        (["A", "B", "C"], "B", CertificateChain.Position.intermediate(index: 1)),
        (["A", "B", "C"], "C", CertificateChain.Position.root),
    ])
    func matchReportsPosition(
        hashes: [String],
        pinned: String,
        expected: CertificateChain.Position
    ) {
        let result = sut.match(
            chain: CertificateFactory.chain(hashes: hashes),
            host: "example.com",
            pinSets: [PinSetFactory.make(domain: "example.com", hashes: [pinned])]
        )
        #expect(result == .matched(level: expected))
    }

    @Test("First match wins when the pin covers several certificates")
    func firstMatchWins() {
        // Pin contains both leaf and root — we expect the leaf (index 0) hit.
        let result = sut.match(
            chain: CertificateFactory.chain(hashes: ["LEAF", "ROOT"]),
            host: "example.com",
            pinSets: [PinSetFactory.make(domain: "example.com", hashes: ["LEAF", "ROOT"])]
        )
        #expect(result == .matched(level: .leaf))
    }

    // MARK: - Regression: bare host vs. stored domain carrying a port
    //
    // The scenario from the logs: the saved pin domain was "host:443" while
    // url.host() returns the host without a port. This assertion intentionally
    // demands the correct (port-insensitive) behaviour and will pass only once
    // the domain is normalised in PinMatcher.resolve or on save.
    @Test("A port in the stored domain should not break matching")
    func portInPinDomainShouldStillMatch() {
        let result = sut.match(
            chain: CertificateFactory.chain(hashes: ["LEAF"]),
            host: "sha256.badssl.com",
            pinSets: [PinSetFactory.make(domain: "sha256.badssl.com:443", hashes: ["LEAF"])]
        )
        #expect(result == .matched(level: .leaf))
    }
}
