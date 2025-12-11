//
//  2.swift
//  LoggingKit
//
//  Created by Denis Esie on 11.12.2025.
//

import LoggingKit

// Define a custom logger type that conforms to Loggable
struct CustomLogger: Loggable {
    static let subsystem = "Custom.Subsystem"
}

func InjectedLoggerExample() {
    // Pass the type (not an instance) to the macro
    #logInfo("Logging something important with an injected logger", logger: CustomLogger.self)
}
