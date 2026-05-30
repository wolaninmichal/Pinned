//
//  ChainExtractor.swift
//  Pinned
//
//  Created by Michał Wolanin on 26/05/2026.
//

import Foundation
import Security

/// Maps a system `SecTrust` object into our `Sendable` domain `CertificateChain`, computing the SPKI hash for every certificate along the way.
///
/// All Security-framework interaction is confined to this type and `SPKIHasher`, so the rest of the app never
/// has to touch `SecTrust`, `SecCertificate`, or `SecKey`.
///
/// Subject summaries come from `SecCertificateCopySubjectSummary` (cross-platform),
/// the issuer and validity dates are parsed from the raw DER via `X509Metadata`,
/// because the equivalent `SecCertificateCopyValues` API is macOS-only.
public struct ChainExtractor: Sendable {

    private let hasher: SPKIHasher

    public nonisolated init(hasher: SPKIHasher = SPKIHasher()) {
        self.hasher = hasher
    }

    func extract(from trust: SecTrust) throws -> CertificateChain {
        /// 🔑 [4/6] extract — copy the certificate chain out of the opaque SecTrust
        /// object so the rest of the app can work with plain, Sendable values.
        Log.debug("🔑 [4/6] Extracting the certificate chain from SecTrust")

        guard let secCertificates = SecTrustCopyCertificateChain(trust) as? [SecCertificate],
              !secCertificates.isEmpty
        else {
            Log.error("ChainExtractor - SecTrustCopyCertificateChain produced an empty chain")
            throw InspectionError.emptyChain
        }
        Log.info("ChainExtractor - chain contains \(secCertificates.count) certificate(s)")

        let certificates = try secCertificates.enumerated().map { index, secCertificate in
            try makeCertificate(from: secCertificate, index: index)
        }
        return CertificateChain(certificates: certificates)
    }
}

// MARK: - Per-certificate mapping
private extension ChainExtractor {

    func makeCertificate(from secCertificate: SecCertificate, index: Int) throws -> Certificate {
        /// Per-certificate prep that feeds step [5/6]: pull out the public key and
        /// classify it. The key type decides which ASN.1 header SPKIHasher prepends.
        Log.debug("ChainExtractor - [\(index)] reading public key and classifying key type")

        guard let publicKey = SecCertificateCopyKey(secCertificate) else {
            Log.error("ChainExtractor - [\(index)] SecCertificateCopyKey returned nil")
            throw InspectionError.hashingFailed
        }
        guard let keyType = KeyTypeDetector.detect(from: publicKey) else {
            Log.error("ChainExtractor - [\(index)] unsupported key type")
            throw InspectionError.hashingFailed
        }
        guard let spkiHash = hasher.hash(publicKey: publicKey, keyType: keyType) else {
            Log.error("ChainExtractor - [\(index)] SPKI hashing failed")
            throw InspectionError.hashingFailed
        }

        let subject = SecCertificateCopySubjectSummary(secCertificate) as String? ?? "Unknown"

        /// iOS has no API for issuer/validity — parse the DER ourselves.
        let der = SecCertificateCopyData(secCertificate) as Data
        let metadata = X509Metadata.parse(der: der)
        if metadata == nil {
            Log.warning("ChainExtractor - [\(index)] DER metadata parse failed, falling back to defaults")
        }

        let issuer = metadata?.issuerCommonName ?? "Unknown"
        let notBefore = metadata?.notBefore ?? Date()
        let notAfter = metadata?.notAfter ?? Date()

        Log.debug("ChainExtractor - [\(index)] subject=\(subject) issuer=\(issuer) keyType=\(keyType.displayName)")
        return Certificate(
            subjectCommonName: subject,
            issuerCommonName: issuer,
            keyType: keyType,
            spkiHash: spkiHash,
            notBefore: notBefore,
            notAfter: notAfter
        )
    }
}
