//
//  Localization.swift
//  Pinned
//
//  Created by Michał Wolanin on 22/05/2026.
//

import Foundation

public extension LocalizedStringResource {

    enum Inspect {
        public static let eyebrow = LocalizedStringResource("inspect.header.eyebrow")
        public static let title = LocalizedStringResource("inspect.header.title")
        public static let placeholder = LocalizedStringResource("inspect.placeholder.message")
        public static let errorTitle = LocalizedStringResource("inspect.error.title")
        public static let invalidURL = LocalizedStringResource("inspect.error.invalidURL")
        public static let standardValidation = LocalizedStringResource("inspect.error.standardValidation")
        public static let emptyChain = LocalizedStringResource("inspect.error.emptyChain")
        public static let hashingFailed = LocalizedStringResource("inspect.error.hashingFailed")

        public static func tlsHandshake(_ reason: String) -> LocalizedStringResource {
            LocalizedStringResource("inspect.error.tlsHandshake", defaultValue: "TLS handshake failed: \(reason)")
        }
    }

    enum Chain {
        public static func count(_ count: Int) -> LocalizedStringResource {
            LocalizedStringResource("chain.header.count", defaultValue: "CHAIN · \(count) CERTS")
        }
    }

    enum Cert {
        public static let spkiHash = LocalizedStringResource("certificate.label.spkiHash")
        public static let positionLeaf = LocalizedStringResource("certificate.position.leaf")
        public static let positionRoot = LocalizedStringResource("certificate.position.root")

        public static func issuedBy(_ issuer: String) -> LocalizedStringResource {
            LocalizedStringResource("certificate.issuedBy", defaultValue: "issued by \(issuer)")
        }

        public static func positionIntermediate(_ index: Int) -> LocalizedStringResource {
            LocalizedStringResource("certificate.position.intermediate", defaultValue: "INTERMEDIATE · \(index)")
        }
    }

    enum Match {
        public static let matchedTitle = LocalizedStringResource("match.matched.title")
        public static let mismatchTitle = LocalizedStringResource("match.mismatch.title")
        public static let mismatchSubtitle = LocalizedStringResource("match.mismatch.subtitle")
        public static let levelLeaf = LocalizedStringResource("match.level.leaf")
        public static let levelRoot = LocalizedStringResource("match.level.root")

        public static func matchedSubtitle(_ level: String) -> LocalizedStringResource {
            LocalizedStringResource("match.matched.subtitle", defaultValue: "matched on \(level)")
        }

        public static func levelIntermediate(_ index: Int) -> LocalizedStringResource {
            LocalizedStringResource("match.level.intermediate", defaultValue: "intermediate (index \(index))")
        }
    }

    enum Tab {
        public static let inspect = LocalizedStringResource("tab.inspect")
        public static let pins = LocalizedStringResource("tab.pins")
    }

    enum Pins {
        public static let eyebrow = LocalizedStringResource("pins.header.eyebrow")
        public static let title = LocalizedStringResource("pins.title")
        public static let emptyTitle = LocalizedStringResource("pins.empty.title")
        public static let emptyMessage = LocalizedStringResource("pins.empty.message")
        public static let emptyAction = LocalizedStringResource("pins.empty.action")
    }
}
