//
//  ASN1Headers.swift
//  Pinned
//
//  Created by Michał Wolanin on 26/05/2026.
//

import Foundation

/// ASN.1 prefixes prepended to the raw public key bytes to reconstruct a full `SubjectPublicKeyInfo` (SPKI) structure as defined in RFC 5280.
///
/// `SecKeyCopyExternalRepresentation` returns only the bare key material.
/// - RSA -> PKCS#1 `RSAPublicKey` (modulus + exponent), no algorithm identifier
/// - ECDSA -> the uncompressed curve point (`0x04 || X || Y`)
///
/// A pin, however, is the SHA-256 of the whole SPKI - `SEQUENCE { AlgorithmIdentifier, BIT STRING(publicKey) }`
///
/// These byte arrays encode the `AlgorithmIdentifier` plus the opening `BIT STRING` tag for each key type. Get the wrong header
/// and the hash silently diverges from `openssl` / TrustKit — which is the single most common way hand-rolled pinning breaks.
enum ASN1Headers {

    /// rsaEncryption OID (1.2.840.113549.1.1.1) + NULL params.
    /// Size-independent. The modulus length lives inside the PKCS#1 body, so the same header serves RSA 2048 and 4096.
    static let rsa: [UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09,
        0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]

    /// id-ecPublicKey (1.2.840.10045.2.1) + secp256r1 (1.2.840.10045.3.1.7).
    static let ecdsaP256: [UInt8] = [
        0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86,
        0x48, 0xce, 0x3d, 0x02, 0x01, 0x06, 0x08, 0x2a,
        0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03,
        0x42, 0x00
    ]

    /// id-ecPublicKey + secp384r1 (1.3.132.0.34).
    static let ecdsaP384: [UInt8] = [
        0x30, 0x76, 0x30, 0x10, 0x06, 0x07, 0x2a, 0x86,
        0x48, 0xce, 0x3d, 0x02, 0x01, 0x06, 0x05, 0x2b,
        0x81, 0x04, 0x00, 0x22, 0x03, 0x62, 0x00
    ]

    /// id-Ed25519 (1.3.101.112) per RFC 8410.
    static let ed25519: [UInt8] = [
        0x30, 0x2a, 0x30, 0x05, 0x06, 0x03, 0x2b, 0x65,
        0x70, 0x03, 0x21, 0x00
    ]

    static func header(for keyType: KeyType) -> [UInt8] {
        switch keyType {
        case .rsa2048, .rsa4096: rsa
        case .ecdsaP256: ecdsaP256
        case .ecdsaP384: ecdsaP384
        case .ed25519: ed25519
        }
    }
}
