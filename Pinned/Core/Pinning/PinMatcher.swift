//
//  PinMatcher.swift
//  Pinned
//
//  Created by Michał Wolanin on 26/05/2026.
//

import Foundation

/// Decides whether an inspected chain satisfies the pins the user saved for a host.
///
/// Two responsibilities, both deliberately kept here so they stay trivially testable:
/// 1. `Resolve` the applicable `PinSet` for a host (an exact domain, or a parent domain when `includeSubdomains` is set).
/// 2. `Match` — a single pinned hash matching *any* certificate in the chain is a pass, mirroring production behaviour (TrustKit accepts on the first match).
///    The matched position is reported back: a hit on the intermediate rather than the leaf is a hint that the leaf pin is stale and should be rotated.
public struct PinMatcher: Sendable {

    public nonisolated init() {}

    public func match(chain: CertificateChain, host: String, pinSets: [PinSet]) -> MatchResult {
        // 🔑 [6/6] match — compare the freshly computed hashes against the pins the
        // user saved for this host. One hash matching any certificate is a pass.
        Log.debug("🔑 [6/6] Matching computed hashes against saved pins for \(host)")
        Log.debug("PinMatcher - \(pinSets.count) saved pin set(s) to consider")

        guard let pinSet = resolve(host: host, in: pinSets) else {
            Log.info("PinMatcher - no pin set applies to \(host) -> noPinsForDomain")
            return .noPinsForDomain
        }
        guard !pinSet.hashes.isEmpty else {
            Log.warning("PinMatcher - pin set for \(pinSet.domain) contains no hashes -> noPinsForDomain")
            return .noPinsForDomain
        }

        Log.debug("PinMatcher - matching against \(pinSet.hashes.count) pin(s) for \(pinSet.domain)")
        let pinned = Set(pinSet.hashes)

        for (index, certificate) in chain.certificates.enumerated() where pinned.contains(certificate.spkiHash) {
            let position = chain.position(at: index)
            Log.info("PinMatcher - match at \(String(describing: position)) — \(certificate.spkiHash)")
            return .matched(level: position)
        }

        Log.warning("PinMatcher - no pinned hash matched any certificate in the chain → mismatch")
        return .mismatch
    }
}

// MARK: - Domain resolution
private extension PinMatcher {
    func resolve(host: String, in pinSets: [PinSet]) -> PinSet? {
        let normalizedHost = normalize(host)

        if let exact = pinSets.first(where: { normalize($0.domain) == normalizedHost }) {
            Log.debug("PinMatcher - exact domain match on \(exact.domain)")
            return exact
        }

        let parent = pinSets.first { pinSet in
            pinSet.includeSubdomains
            && normalizedHost.hasSuffix(".\(normalize(pinSet.domain))")
        }
        if let parent {
            Log.debug("PinMatcher - subdomain match — \(host) covered by \(parent.domain)")
        }
        return parent
    }

    /// Lowercases and discards a trailing `:port` ("host:443" → "host").
    /// An IPv6 literal in brackets ("[2001:db8::1]") is left untouched, because
    /// there is no digit-only run after its final colon.
    func normalize(_ domain: String) -> String {
        let lower = domain.lowercased()
        guard let colon = lower.lastIndex(of: ":") else { return lower }
        let port = lower[lower.index(after: colon)...]
        guard !port.isEmpty, port.allSatisfy(\.isNumber) else { return lower }
        return String(lower[..<colon])
    }
}
