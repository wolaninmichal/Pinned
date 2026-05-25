//
//  PinsRoute.swift
//  Pinned
//
//  Created by Michał Wolanin on 22/05/2026.
//

import Foundation

public enum PinsRoute: Identifiable, Hashable {
    case create
    case edit(PinSet)

    public var id: String {
        switch self {
        case .create: "create"
        case .edit(let pinSet): "edit-\(pinSet.id.uuidString)"
        }
    }
}
