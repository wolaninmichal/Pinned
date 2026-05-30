//
//  CertificateChainTests.swift
//  PinnedTests
//
//  Created by Michał Wolanin on 27/05/2026.
//

import Testing
@testable import Pinned

@Suite("CertificateChain")
struct CertificateChainTests {

    @Test("An empty chain has no leaf")
    func emptyHasNoLeaf() {
        #expect(CertificateChain(certificates: []).leaf == nil)
    }

    @Test("A single certificate is the leaf, not the root")
    func singleCertIsLeaf() {
        let chain = CertificateFactory.chain(hashes: ["only"])
        #expect(chain.position(at: 0) == .leaf)   // guarded by count > 1
        #expect(chain.leaf?.spkiHash == "only")
    }

    @Test("Two certificates: leaf + root, no intermediates")
    func twoCerts() {
        let chain = CertificateFactory.chain(hashes: ["leaf", "root"])
        #expect(chain.position(at: 0) == .leaf)
        #expect(chain.position(at: 1) == .root)
    }

    @Test("Three certificates: leaf, intermediate(1), root")
    func threeCerts() {
        let chain = CertificateFactory.chain(hashes: ["leaf", "mid", "root"])
        #expect(chain.position(at: 0) == .leaf)
        #expect(chain.position(at: 1) == .intermediate(index: 1))
        #expect(chain.position(at: 2) == .root)
    }
}
