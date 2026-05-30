//
//  KeyTypeDetector.swift
//  Pinned
//
//  Created by Michał Wolanin on 26/05/2026.
//

import Foundation
import Security

enum KeyTypeDetector {

    static func detect(from key: SecKey) -> KeyType? {
        guard let attributes = SecKeyCopyAttributes(key) as? [String: Any] else {
            Log.error("KeyTypeDetector: SecKeyCopyAttributes returned nil")
            return nil
        }

        let rawType = attributes[kSecAttrKeyType as String] as? String
        let sizeInBits = attributes[kSecAttrKeySizeInBits as String] as? Int ?? 0
        Log.debug("KeyTypeDetector: rawType=\(rawType ?? "nil") sizeInBits=\(sizeInBits)")

        let rsa = kSecAttrKeyTypeRSA as String
        let ecPrimeRandom = kSecAttrKeyTypeECSECPrimeRandom as String

        switch rawType {
        case rsa:
            switch sizeInBits {
            case 2048: return .rsa2048
            case 4096: return .rsa4096
            default:
                Log.warning("KeyTypeDetector: unsupported RSA size \(sizeInBits)")
                return nil
            }

        case ecPrimeRandom:
            switch sizeInBits {
            case 256: return .ecdsaP256
            case 384: return .ecdsaP384
            default:
                Log.warning("KeyTypeDetector: unsupported EC size \(sizeInBits)")
                return nil
            }

        case "1.3.101.112":
            return .ed25519

        default:
            Log.warning("KeyTypeDetector: unrecognised key type \(rawType ?? "nil")")
            return nil
        }
    }
}
