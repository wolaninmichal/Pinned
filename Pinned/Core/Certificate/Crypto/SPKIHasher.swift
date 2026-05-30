//
//  SPKIHasher.swift
//  Pinned
//
//  Created by Michał Wolanin on 26/05/2026.
//

import Foundation
import Security
import CryptoKit

/// Computes the base64-encoded SHA-256 of a certificate's `SubjectPublicKeyInfo` (SPKI). This number is the pin — it
/// is what we store and what we compare a live connection against.
///
/// The output is byte-for-byte identical to the OpenSSL pipeline below, which is
/// exactly the value TrustKit and other pinning libraries expect:
///
///     openssl x509 -in cert.pem -pubkey -noout \
///       | openssl pkey -pubin -outform der \
///       | openssl dgst -sha256 -binary \
///       | openssl enc -base64
///
/// ### What an SPKI actually looks like?
/// The thing we hash is the whole SubjectPublicKeyInfo, not just the key bits:
///
///     SubjectPublicKeyInfo ::= SEQUENCE {
///       algorithm   AlgorithmIdentifier { algorithm OID, parameters },   <- the ASN.1 header
///       publicKey   BIT STRING { rawKeyBytes }                           <- what Sec* gives us
///     }
///
/// `SecKeyCopyExternalRepresentation` hands back only the inner raw key material:
///   - RSA -> a PKCS#1 `RSAPublicKey` (modulus + exponent), no algorithm identifier,
///   - ECDSA -> the uncompressed curve point (`0x04 || X || Y`).
///
/// So we must prepend the matching algorithm header (see `ASN1Headers`) to rebuild the full SPKI before hashing. Get the header wrong and
/// the digest silently diverges from OpenSSL / TrustKit — the single most common way hand-rolled pinning breaks.
///
/// ### Pipeline
/// 1. `SecCertificateCopyKey`             -> extract the public key
/// 2. `KeyTypeDetector`                   -> classify it (this drives the ASN.1 header)
/// 3. `SecKeyCopyExternalRepresentation`  -> serialise to raw bytes
/// 4. prepend `ASN1Headers.header(for:)`  -> raw key becomes a full SPKI
/// 5. `SHA256` + base64                   -> the pin
public struct SPKIHasher: Sendable {

    public nonisolated init() {  }

    /// Convenience entry point used by tests with on-disk certificate fixtures.
    public func hash(certificate: SecCertificate) -> String? {
        Log.debug("SPKIHasher - extracting public key from certificate")
        guard let publicKey = SecCertificateCopyKey(certificate) else {
            Log.error("SPKIHasher - SecCertificateCopyKey returned nil")
            return nil
        }
        guard let keyType = KeyTypeDetector.detect(from: publicKey) else {
            return nil
        }
        return hash(publicKey: publicKey, keyType: keyType)
    }

    /// Hot path. The chain extractor has already resolved the key type, so we skip re-detection and hash directly.
    public func hash(publicKey: SecKey, keyType: KeyType) -> String? {
        // 🔑 [5/6] the pin itself — rebuild the full SubjectPublicKeyInfo
        // (ASN.1 algorithm header + raw key), then SHA-256 + base64. This is the
        // one value pinning compares; the header is what makes it match OpenSSL.
        Log.debug("🔑 [5/6] Computing SPKI pin for a \(keyType.displayName) key")

        var error: Unmanaged<CFError>?
        guard let rawKey = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            let message = error?.takeRetainedValue().localizedDescription ?? "unknown"
            Log.error("SPKIHasher - SecKeyCopyExternalRepresentation failed — \(message)")
            return nil
        }

        // Step 4: prepend the algorithm header so the raw key becomes a full SPKI.
        let header = ASN1Headers.header(for: keyType)

        var spki = Data(header)
        spki.append(rawKey)

        Log.debug("SPKIHasher - SPKI = \(header.count)B header + \(rawKey.count)B key = \(spki.count)B total")

        // Step 5: SHA-256 over the reconstructed SPKI, then base64-encode it.
        let digest = SHA256.hash(data: spki)
        let encoded = Data(digest).base64EncodedString()
        Log.debug("SPKIHasher: \(keyType.displayName) → \(encoded)")
        return encoded
    }
}
