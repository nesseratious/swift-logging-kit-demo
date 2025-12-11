//
//  6.swift
//  LoggingKit
//
//  Created by Denis Esie on 11.12.2025.
//

import LoggingKit

struct ExampleFunctionLogger: Loggable {
    static let subsystem = "Example"
    
    func run() {
        logInfo("Logging from function")
        logWarning("Logging from function")
        logCritical("Logging from function")
    }
}
