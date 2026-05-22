//
//  KeyType.swift
//  Pinned
//
//  Created by Michał Wolanin on 20/05/2026.
//

import Foundation

public enum KeyType: Sendable, Equatable {
    case rsa2048
    case rsa4096
    case ecdsaP256
    case ecdsaP384
    case ed25519

    public var displayName: String {
        switch self {
        case .rsa2048: "RSA 2048"
        case .rsa4096: "RSA 4096"
        case .ecdsaP256: "ECDSA P-256"
        case .ecdsaP384: "ECDSA P-384"
        case .ed25519: "Ed25519"
        }
    }
}
