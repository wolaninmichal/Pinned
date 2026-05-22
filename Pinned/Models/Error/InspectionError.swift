//
//  InspectionError.swift
//  Pinned
//
//  Created by Michał Wolanin on 22/05/2026.
//

import Foundation

public enum InspectionError: Error, Sendable, Equatable {
    case invalidURL
    case tlsHandshakeFailed(underlying: String)
    case standardValidationFailed
    case emptyChain
    case hashingFailed
}
