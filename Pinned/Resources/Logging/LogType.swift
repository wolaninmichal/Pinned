//
//  LogType.swift
//  Pinned
//
//  Created by Michał Wolanin on 15/03/2026.
//

import Foundation

enum LogType {
    case info
    case debug
    case warning
    case error
    case initObj
    case deinitObj
    case database

    var prefix: String {
        switch self {
        case .info: "INFO 💡"
        case .debug: "DEBUG 📖"
        case .warning: "WARNING 🧨"
        case .error: "ERROR 🔥"
        case .initObj: "INIT 🐣"
        case .deinitObj: "DEINIT 💀"
        case .database: "DATABASE 📤"
        }
    }
}
