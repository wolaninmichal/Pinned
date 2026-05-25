//
//  CertificateChain.swift
//  Pinned
//
//  Created by Michał Wolanin on 20/05/2026.
//

import Foundation

public struct CertificateChain: Sendable, Equatable {
    public enum Position: Sendable, Equatable {
        case leaf
        case intermediate(index: Int)
        case root
    }

    public let certificates: [Certificate]

    public init(certificates: [Certificate]) {
        self.certificates = certificates
    }

    public var leaf: Certificate? { certificates.first }

    public func position(at index: Int) -> Position {
        if index == 0 { return .leaf }
        if index == certificates.count - 1 && certificates.count > 1 { return .root }
        return .intermediate(index: index)
    }
}
