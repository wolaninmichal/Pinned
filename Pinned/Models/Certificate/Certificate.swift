//
//  Certificate.swift
//  Pinned
//
//  Created by Michał Wolanin on 20/05/2026.
//

import Foundation

public struct Certificate: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let subjectCommonName: String
    public let issuerCommonName: String
    public let keyType: KeyType
    public let spkiHash: String
    public let notBefore: Date
    public let notAfter: Date

    public init(
        id: UUID = UUID(),
        subjectCommonName: String,
        issuerCommonName: String,
        keyType: KeyType,
        spkiHash: String,
        notBefore: Date,
        notAfter: Date
    ) {
        self.id = id
        self.subjectCommonName = subjectCommonName
        self.issuerCommonName = issuerCommonName
        self.keyType = keyType
        self.spkiHash = spkiHash
        self.notBefore = notBefore
        self.notAfter = notAfter
    }
}
