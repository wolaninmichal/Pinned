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

    private let inspector: CertificateInspector
    private let pinRepository: PinRepository
    private let matcher: PinMatcher

    public init(
        inspector: CertificateInspector = URLSessionCertificateInspector(),
        pinRepository: PinRepository,
        matcher: PinMatcher = PinMatcher()
    ) {
        self.inspector = inspector
        self.pinRepository = pinRepository
        self.matcher = matcher
    }

    // MARK: - Intents
    public func inspect() async {
        guard let url = Self.normalizedURL(from: urlText), let host = url.host() else {
            Log.warning("InspectViewModel: could not parse a host from \"\(urlText)\"")
            state = .failed(.invalidURL)
            return
        }

        Log.info("InspectViewModel: inspecting \(host)")
        state = .loading

        do {
            /// 1. Pull the live chain (TLS handshake + SPKI hashing).
            let chain = try await inspector.inspect(url: url)

            /// 2. Load saved pins and resolve the verdict for this host.
            /// A repository failure is non-fatal — we still show the chain, just without a match verdict.
            let pinSets = await loadPinSets()
            let match = matcher.match(chain: chain, host: host, pinSets: pinSets)

            Log.info("InspectViewModel: finished — \(String(describing: match))")
            state = .results(chain: chain, match: match)
        } catch let error as InspectionError {
            Log.error("InspectViewModel: inspection failed — \(error)")
            state = .failed(error)
        } catch {
            Log.error("InspectViewModel: unexpected failure — \(error.localizedDescription)")
            state = .failed(.tlsHandshakeFailed(underlying: error.localizedDescription))
        }
    }

    public func reset() {
        state = .idle
        urlText = ""
    }
}

// MARK: - Helpers
private extension InspectViewModel {

    func loadPinSets() async -> [PinSet] {
        do {
            return try await pinRepository.fetchAll()
        } catch {
            Log.warning("InspectViewModel: could not load pins (\(error.localizedDescription)) — continuing without a verdict")
            return []
        }
    }

    /// Accepts bare hosts (`api.example.com`) as well as full URLs, defaulting to
    /// HTTPS — plain HTTP makes no sense for a pinning tool.
    static func normalizedURL(from text: String) -> URL? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        let normalized = trimmed.contains("://") ? trimmed : "https://\(trimmed)"
        guard let url = URL(string: normalized), url.host() != nil else { return nil }
        return url
    }
}
