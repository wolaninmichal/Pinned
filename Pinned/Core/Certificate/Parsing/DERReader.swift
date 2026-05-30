//
//  DERReader.swift
//  Pinned
//
//  Created by Michał Wolanin on 26/05/2026.
//

import Foundation

/// `DERReader` — a small, crash-proof cursor for walking the raw bytes of an X.509 certificate.
///
/// When you open `https://bank.com`, the app opens a TLS connection to a server.
/// During the handshake the server presents a certificate: a signed digital document that effectively says "I am bank.com,
/// and a trusted Certificate Authority (CA) vouches for me." iOS checks that signature against its built-in list of trusted CAs; if everything lines up,
/// the connection is allowed to continue. Certificate pinning then adds a second, app-controlled check on top.
///
/// A certificate is just a file, and that file has a strict binary format called `X.509`. X.509 is serialised using the `DER` coding
/// (Distinguished Encoding Rules). So before we can read anything human-friendly — the issuer name, the validity dates,
/// the public key — we first have to decode DER.
///
/// DER stores everything as a stream of TLV triplets. Each value answers three questions, in this exact order:
///
///   - `T — Tag` - what kind of value is this? (integer, string, sequence, ...),
///   - `L — Length` - how many bytes long is the value?,
///   - `V — Value` - the content itself.
///
/// A single integer holding the value `7` is therefore three bytes:
///
///     02   01   07
///     │    │    └── Value - the number 7
///     │    └─────── Length - 1 byte of content
///     └──────────── Tag - 0x02 = INTEGER
///
/// TLVs can nest. A `SEQUENCE` (tag `0x30`) is a container whose Value is itself a run of more TLVs. That nesting is how an entire certificate \
/// is built — sequences inside sequences, all the way down.
///
/// ### A worked example
///
///     position:   [0]  [1]  [2]  [3]  [4]  [5]  [6]  [7]  [8]  [9]
///     byte:       30   08   02   01   01   06   03   55   04   03
///
///     [0]  tag = 0x30 -> SEQUENCE (a container holding other TLVs)
///     [1]  len = 0x08 -> its content is 8 bytes long, occupying [2]...[9]
///     [2]  tag = 0x02 -> INTEGER
///     [3]  len = 0x01 -> 1 byte of content
///     [4]  val = 0x01 -> the number 1
///     [5]  tag = 0x06 -> OID (an Object Identifier — a standard code name)
///     [6]  len = 0x03 -> 3 bytes of content
///     [7…9] val = 55 04 03 -> this OID means "commonName" (the entity's name)
///
/// ### What this type does (and does not do)
/// `DERReader` is a forward-only cursor over a byte buffer. Each call to `read()` decodes exactly one TLV at the current position and advances past it.
/// It never interprets meaning — it only reports *what tag* a value carries and `where` its bytes live. The certificate-specific logic
/// (which field is the issuer, which is the validity window) sits one layer up, in `X509Metadata`.
///
/// It is deliberately defensive. Certificates arrive from the network and may be truncated or malformed, so every bounds check returns `nil`
/// rather than trapping. A parser that can crash on hostile input is a security bug, not just a robustness one.

struct DERReader {

    /// A bookmark left behind by `read()`. It records two facts about one decoded TLV:
    ///   - `tag` - what kind of value it was (e.g. `0x30` SEQUENCE, `0x02` INTEGER),
    ///   - `range` - where its `content` (the V in TLV) lives inside the buffer.
    /// The bytes themselves are never copied here, only their location — which makes descending into a nested SEQUENCE essentially free.
    struct Element {
        let tag: UInt8
        let range: Range<Int>
    }

    private let bytes: [UInt8]
    private var index: Int
    private let end: Int

    init(_ data: Data) {
        self.bytes = [UInt8](data)
        self.index = 0
        self.end = bytes.count
    }

    private init(bytes: [UInt8], range: Range<Int>) {
        self.bytes = bytes
        self.index = range.lowerBound
        self.end = range.upperBound
    }

    /// Reads one TLV (Tag–Length–Value) at the current cursor position and advanc past it. Returns `nil` if the data is
    /// truncated or malform — it never crashes on bad input.
    mutating func read() -> Element? {
        /// #1 TAG
        guard index < end else { return nil }
        /// Grab the tag byte (0x02 = INTEGER, 0x30 = SEQUENCE, 0x06 = OID, ...).
        let tag = bytes[index]
        /// Step the cursor one byte forward — past the tag.
        index += 1

        /// #2 LENGTH
        guard index < end else { return nil }
        /// Read the first length byte.
        var length = Int(bytes[index])
        /// Step past the length byte.
        index += 1

        /// #3 LONG-FORM LENGTH
        /// If bit 7 of the length byte is set, the length is in "long form" - this first byte no longer holds the length itself, it tells us how many of the
        /// following bytes do. This is needed for anything longer than 127 bytes — RSA keys, full certificates, and so on.
        if length & 0x80 != 0 {
            /// The low 7 bits say how many length bytes follow.
            let byteCount = length & 0x7F

            /// Sanity-check that count before trusting it:
            /// - byteCount must be >= 1 (a lone 0x80 is invalid DER),
            /// - byteCount must be <= 4 (more would imply a > 4 GB value — impossible here),
            /// - those bytes must actually exist inside the buffer.
            guard
                byteCount > 0,
                byteCount <= 4,
                index + byteCount <= end
            else {
                return nil
            }

            /// Reassemble the real length, big-endian: each new byte shifts the
            /// accumulator left by 8 bits (×256) and ORs in the next byte.
            /// e.g. bytes 0x01, 0x0E -> (0 << 8 | 0x01) = 1 → (1 << 8 | 0x0E) = 270.
            length = 0
            for _ in 0..<byteCount {
                length = (length << 8) | Int(bytes[index])
                index += 1
            }
        }

        /// #4 CONTENT RANGE
        /// - length must not be negative,
        /// - all `length` bytes of content must exist inside the buffer.
        guard
            length >= 0,
            index + length <= end
        else {
            return nil
        }

        let contentRange = index..<(index + length)
        index += length
        /// Hand back what kind of value it was (tag) and where its bytes live (range).
        return Element(tag: tag, range: contentRange)
    }

    /// A new reader bounded to the content of `element` — used to descend into the body of a SEQUENCE or SET.
    func reader(for element: Element) -> DERReader {
        DERReader(bytes: bytes, range: element.range)
    }

    func contentBytes(of element: Element) -> [UInt8] {
        Array(bytes[element.range])
    }

    func string(of element: Element) -> String? {
        String(bytes: bytes[element.range], encoding: .utf8)
            ?? String(bytes: bytes[element.range], encoding: .ascii)
    }
}
