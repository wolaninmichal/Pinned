//
//  MatchResult.swift
//  Pinned
//
//  Created by Michał Wolanin on 22/05/2026.
//

import Foundation

public enum MatchResult: Sendable, Equatable {
    case matched(level: CertificateChain.Position)
    case noPinsForDomain
    case mismatch
}
