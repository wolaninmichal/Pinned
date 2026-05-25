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
    
    enum PinEditor {
        public static let createTitle = LocalizedStringResource("pinEditor.create.title")
        public static let editTitle = LocalizedStringResource("pinEditor.edit.title")
        public static let createEyebrow = LocalizedStringResource("pinEditor.create.eyebrow")
        public static let editEyebrow = LocalizedStringResource("pinEditor.edit.eyebrow")
        
        public static let domainLabel = LocalizedStringResource("pinEditor.domain.label")
        public static let domainPrompt = LocalizedStringResource("pinEditor.domain.prompt")
        public static let includeSubdomains = LocalizedStringResource("pinEditor.includeSubdomains")
        
        public static let hashesLabel = LocalizedStringResource("pinEditor.hashes.label")
        public static let hashPrompt = LocalizedStringResource("pinEditor.hashes.prompt")
        public static let addHash = LocalizedStringResource("pinEditor.hashes.add")
        public static let hashesEmpty = LocalizedStringResource("pinEditor.hashes.empty")
        
        public static let invalidHashFormat = LocalizedStringResource("pinEditor.validation.invalidFormat")
        public static let duplicateHash = LocalizedStringResource("pinEditor.validation.duplicate")
        
        public static let cancel = LocalizedStringResource("pinEditor.action.cancel")
        public static let save = LocalizedStringResource("pinEditor.action.save")
        
        public static func hashCount(_ count: Int) -> LocalizedStringResource {
            LocalizedStringResource(
                "pinEditor.hashes.count",
                defaultValue: "\(count) PINNED \(count == 1 ? "HASH" : "HASHES")"
            )
        }
    }
     
    enum PinRow {
        public static let subdomainsBadge = LocalizedStringResource("pinRow.subdomains")
        
        public static func pinCount(_ count: Int) -> LocalizedStringResource {
            LocalizedStringResource(
                "pinRow.pinCount",
                defaultValue: "\(count) pin\(count == 1 ? "" : "s")"
            )
        }
    }
}
