//
//  DERReaderTests.swift
//  PinnedTests
//
//  Created by Michał Wolanin on 27/05/2026.
//

import Testing
import Foundation
@testable import Pinned

@Suite("DERReader")
struct DERReaderTests {

    @Test("Reads nested TLV inside a SEQUENCE")
    func nestedSequence() throws {
        let der = Data([
            0x30, 0x08,
            0x02, 0x01, 0x01,
            0x06, 0x03, 0x55, 0x04, 0x03
        ])
        var root = DERReader(der)

        let seqElement = root.read()
        let seq = try #require(seqElement)
        #expect(seq.tag == 0x30)

        var inner = root.reader(for: seq)

        let integerElement = inner.read()
        let integer = try #require(integerElement)
        #expect(integer.tag == 0x02)
        #expect(inner.contentBytes(of: integer) == [0x01])

        let oidElement = inner.read()
        let oid = try #require(oidElement)
        #expect(oid.tag == 0x06)
        #expect(inner.contentBytes(of: oid) == [0x55, 0x04, 0x03])

        let exhausted = inner.read()
        #expect(exhausted == nil)
    }

    @Test("Decodes long-form length (> 127 bytes)")
    func longFormLength() throws {
        let payload = [UInt8](repeating: 0xAB, count: 200)
        var bytes: [UInt8] = [0x04, 0x81, 0xC8]
        bytes.append(contentsOf: payload)

        var reader = DERReader(Data(bytes))

        let elementResult = reader.read()
        let element = try #require(elementResult)

        #expect(element.tag == 0x04)
        #expect(reader.contentBytes(of: element).count == 200)
    }

    @Test("Ranges are absolute — a child reader is independent of the parent cursor")
    func absoluteRangesAllowLateChildReads() throws {
        let der = Data([
            0x30, 0x06,
            0x06, 0x01, 0x2A,
            0x02, 0x01, 0x05
        ])
        var root = DERReader(der)

        let seqElement = root.read()
        let seq = try #require(seqElement)

        var inner = root.reader(for: seq)

        let oidElement = inner.read()
        let oid = try #require(oidElement)

        #expect(inner.contentBytes(of: oid) == [0x2A])
    }

    @Test("A truncated TLV returns nil instead of crashing")
    func truncatedReturnsNil() {
        var reader = DERReader(Data([0x30]))

        let element = reader.read()
        #expect(element == nil)
    }
}
