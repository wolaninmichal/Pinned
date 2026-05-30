//
//  URLSessionCertificateInspector.swift
//  Pinned
//
//  Created by Michał Wolanin on 26/05/2026.
//

import Foundation
import Security

/// Live `CertificateInspector` backed by `URLSession`.
///
/// The trick at the heart of the app: a plain request never exposes the server's certificates — the system validates them internally and
///  hands back only the response. To see the chain we intercept the TLS handshake via a `URLSessionDelegate` and read the `SecTrust` out of
///  the authentication challenge.
///
/// `final class` + all-`Sendable` stored properties means this conforms to
/// `Sendable` without `@unchecked` — only the delegate (which guards its mutable state behind a lock) needs `@unchecked`.
public final class URLSessionCertificateInspector: CertificateInspector {

    private let extractor: ChainExtractor
    private let timeout: TimeInterval

    public nonisolated init(
        extractor: ChainExtractor = ChainExtractor(),
        timeout: TimeInterval = 15
    ) {
        self.extractor = extractor
        self.timeout = timeout
    }

    public func inspect(url: URL) async throws -> CertificateChain {
        Log.info("Inspector: starting inspection of \(url.absoluteString)")

        let delegate = TrustCapturingDelegate(extractor: extractor)
        let session = URLSession(configuration: .ephemeral, delegate: delegate, delegateQueue: nil)
        defer {
            session.finishTasksAndInvalidate()
            Log.debug("Inspector: session invalidated")
        }

        // 🔑 [1/6] handshake — we send a HEAD request purely to make the server present its certificate chain. We never care about the response body, only the TLS challenge the handshake triggers.
        Log.debug("🔑 [1/6] Triggering the TLS handshake (HEAD request)")
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = timeout

        do {
            _ = try await session.data(for: request)
        } catch {
            // A rejection we triggered during validation is more meaningful than the
            // generic "cancelled" transport error URLSession surfaces for it.
            if case .failure(let captured)? = delegate.result {
                Log.error("Inspector: failing with captured error \(captured)")
                throw captured
            }
            Log.error("Inspector: transport error — \(error.localizedDescription)")
            throw InspectionError.tlsHandshakeFailed(underlying: error.localizedDescription)
        }

        switch delegate.result {
        case .success(let chain):
            Log.info("Inspector: succeeded with \(chain.certificates.count) certificate(s)")
            return chain
        case .failure(let error):
            Log.error("Inspector: handshake succeeded but extraction failed \(error)")
            throw error
        case .none:
            Log.error("Inspector: no server-trust challenge was received")
            throw InspectionError.emptyChain
        }
    }
}

/// Captures (and decides on) the server trust presented during the TLS handshake.
///
/// `@unchecked Sendable` - `URLSession` invokes delegate callbacks on its own queue, so the single mutable field is serialised behind an `NSLock`.
/// Everything that crosses back to the inspector (`CertificateChain`, `InspectionError`) is `Sendable`.
private final class TrustCapturingDelegate: NSObject, URLSessionDelegate, @unchecked Sendable {

    private let extractor: ChainExtractor
    private let lock: NSLock = .init()
    private var _result: Result<CertificateChain, InspectionError>?

    init(
        extractor: ChainExtractor
    ) {
        self.extractor = extractor
        super.init()
    }

    var result: Result<CertificateChain, InspectionError>? {
        lock.withLock { _result }
    }

    /// First write wins — a redirect could trigger a second challenge, but we only care about the original endpoint's chain.
    private func storeOnce(_ value: Result<CertificateChain, InspectionError>) {
        lock.withLock { if _result == nil { _result = value } }
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        let space = challenge.protectionSpace
        Log.info("Inspector: auth challenge for \(space.host):\(space.port)")

        /// Stage 1 — only server-trust challenges concern pinning. Anything els (HTTP basic, client cert, NTLM…) gets the system's default behaviour.
        guard space.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            Log.debug("Inspector - \(space.authenticationMethod) is not server trust -> default handling")
            completionHandler(.performDefaultHandling, nil)
            return
        }

        /// Stage 2 — there must actually be a trust object to evaluate.
        guard let serverTrust = space.serverTrust else {
            Log.error("Inspector - server trust object unavailable")
            storeOnce(.failure(.standardValidationFailed))
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // 🔑 [2/6] capture — the authentication challenge is the only hook where the raw server chain is reachable; a normal request hides it from us entirely.
        Log.debug("🔑 [2/6] Captured server trust from the TLS challenge")

        // 🔑 [3/6] CA check — baseline system validation: CA chain, expiry, hostname policy. Pinning is layered ON TOP of this, never instead of it;
        // a pinned-but-expired certificate must still be rejected here.
        Log.debug("🔑 [3/6] Baseline CA validation (SecTrustEvaluateWithError)")
        var trustError: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &trustError) else {
            let message = trustError.map { CFErrorCopyDescription($0) as String } ?? "unknown"
            Log.error("Inspector - standard validation failed — \(message)")
            storeOnce(.failure(.standardValidationFailed))
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        Log.info("Inspector - standard validation passed")

        /// Stage 4 — hand the trust to ChainExtractor, which copies out the chain and computes an SPKI hash for every certificate (steps [4/6] and [5/6]).
        do {
            let chain = try extractor.extract(from: serverTrust)
            storeOnce(.success(chain))

            /// Stage 5 — accept unconditionally. This is an `inspector`, not a `validator`: we want to surface the chain even when it matches no
            /// pins, so the user can compare it against what they expected. 
            Log.info("Inspector - accepting connection (.useCredential) — inspector never blocks")
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } catch let error as InspectionError {
            Log.error("Inspector - chain extraction failed — \(error)")
            storeOnce(.failure(error))
            completionHandler(.cancelAuthenticationChallenge, nil)
        } catch {
            Log.error("Inspector - unexpected extraction error — \(error.localizedDescription)")
            storeOnce(.failure(.hashingFailed))
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
