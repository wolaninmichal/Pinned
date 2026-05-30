//
//  X509Metadata.swift
//  Pinned
//
//  Created by Michał Wolanin on 26/05/2026.
//

import Foundation

/// Extracts the handful of human-readable fields the UI needs — the issuer common name and the validity window (notBefore / notAfter) — straight
/// from a certificate's DER bytes.
///
/// ### Why parse this by hand
/// `SecCertificateCopyValues` and the `kSecOID...` constants are `macOS-only`. On iOS there is no public API to read the issuer CN or the validity dates,
///  so we walk the `TBSCertificate` ourselves with `DERReader`.
///
/// ### The X.509 structure we are walking
/// A certificate is a `SEQUENCE` of three parts; everything we need lives inside the
/// first one, the `TBSCertificate` ("to-be-signed" body):
///
///     Certificate ::= SEQUENCE {
///       tbsCertificate        TBSCertificate,      <- we descend into this
///       signatureAlgorithm    AlgorithmIdentifier,
///       signatureValue        BIT STRING
///     }
///
///     TBSCertificate ::= SEQUENCE {
///       version         [0] EXPLICIT INTEGER  OPTIONAL,   <- may be absent
///       serialNumber        INTEGER,
///       signature           AlgorithmIdentifier,
///       issuer              Name,             <- we read the CN from here
///       validity            Validity,         <- and the two dates from here
///       subject             Name,
///       subjectPublicKeyInfo …
///     }
///
/// Because `version` is optional, the first field we read is either the `[0]` version wrapper `or` the serialNumber — `parse(der:)` handles both.
enum X509Metadata {

    struct Parsed: Equatable {
        let issuerCommonName: String
        let notBefore: Date
        let notAfter: Date
    }

    /// id-at-commonName — OID 2.5.4.3, whose DER content bytes are `55 04 03`.
    private static let commonNameOID: [UInt8] = [0x55, 0x04, 0x03]

    /// Walks the TBSCertificate just far enough to read the issuer CN and the two
    /// validity dates. Returns `nil` (never crashes) on any malformed input.
    static func parse(der: Data) -> Parsed? {
        var root = DERReader(der)

        guard let certificate = root.read(), certificate.tag == Tag.sequence else {
            Log.warning("X509Metadata: top-level SEQUENCE not found")
            return nil
        }

        var certReader = root.reader(for: certificate)
        guard let tbs = certReader.read(), tbs.tag == Tag.sequence else {
            Log.warning("X509Metadata: TBSCertificate not found")
            return nil
        }

        var tbs0 = certReader.reader(for: tbs)

        // The first field is either the optional [0] version wrapper or, if that is
        // absent, the serialNumber. Read once, and skip the version if we hit it.
        guard var field = tbs0.read() else { return nil }
        if field.tag == Tag.contextZero {
            guard let next = tbs0.read() else { return nil }   // now the serialNumber
            field = next
        }
        // `field` is now the serialNumber (INTEGER) — skip it.
        guard tbs0.read() != nil else { return nil }             // signature AlgorithmIdentifier — skip

        guard let issuer = tbs0.read(), issuer.tag == Tag.sequence,
              let validity = tbs0.read(), validity.tag == Tag.sequence
        else {
            Log.warning("X509Metadata: issuer/validity not found")
            return nil
        }

        let issuerCN = commonName(in: tbs0.reader(for: issuer)) ?? "Unknown"
        guard let (notBefore, notAfter) = dates(in: tbs0.reader(for: validity)) else {
            Log.warning("X509Metadata: could not parse validity dates")
            return nil
        }

        return Parsed(issuerCommonName: issuerCN, notBefore: notBefore, notAfter: notAfter)
    }
}

// MARK: - Name (RDNSequence) -> common name
private extension X509Metadata {

    /// `Name ::= SEQUENCE OF RelativeDistinguishedName`, where each RDN is a
    /// `SET OF AttributeTypeAndValue { type OID, value }`. We return the first CN  we encounter.
    static func commonName(in name: DERReader) -> String? {
        var nameReader = name
        while let rdn = nameReader.read(), rdn.tag == Tag.set {
            var setReader = nameReader.reader(for: rdn)
            while let attribute = setReader.read(), attribute.tag == Tag.sequence {
                var attrReader = setReader.reader(for: attribute)
                guard let oid = attrReader.read(), oid.tag == Tag.oid else { continue }
                guard attrReader.contentBytes(of: oid) == commonNameOID else { continue }
                if let value = attrReader.read() {
                    return attrReader.string(of: value)
                }
            }
        }
        return nil
    }
}

// MARK: - Validity dates
private extension X509Metadata {

    /// `Validity ::= SEQUENCE { notBefore Time, notAfter Time }`, where each `Time`  is either a `UTCTime` or a `GeneralizedTime`.
    static func dates(in validity: DERReader) -> (notBefore: Date, notAfter: Date)? {
        var reader = validity
        guard let before = reader.read(), let after = reader.read(),
              let notBefore = date(tag: before.tag, bytes: reader.contentBytes(of: before)),
              let notAfter = date(tag: after.tag, bytes: reader.contentBytes(of: after))
        else {
            return nil
        }
        return (notBefore, notAfter)
    }

    static func date(tag: UInt8, bytes: [UInt8]) -> Date? {
        guard let raw = String(bytes: bytes, encoding: .ascii) else { return nil }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyyMMddHHmmss'Z'"

        switch tag {
        case Tag.utcTime:
            /// UTCTime is "YYMMDDHHMMSSZ". Per RFC 5280: YY >= 50 -> 19YY, otherwise 20YY.
            guard raw.count >= 2, let yy = Int(raw.prefix(2)) else { return nil }
            let century = yy >= 50 ? "19" : "20"
            return formatter.date(from: century + raw)

        case Tag.generalizedTime:
            /// GeneralizedTime is already "YYYYMMDDHHMMSSZ".
            return formatter.date(from: raw)

        default:
            return nil
        }
    }
}

// MARK: - DER tags
private extension X509Metadata {
    enum Tag {
        static let sequence: UInt8 = 0x30
        static let set: UInt8 = 0x31
        static let oid: UInt8 = 0x06
        static let utcTime: UInt8 = 0x17
        static let generalizedTime: UInt8 = 0x18
        static let contextZero: UInt8 = 0xA0
    }
}
