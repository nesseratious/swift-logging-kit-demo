//
//  ExampleLogger.swift
//  LoggingKit
//
//  Created by Denis Esie on 11.12.2025.
//

import LoggingKit

struct VerboseLogger: Loggable {
    static let subsystem = "Verbose"
    
    func run() {
        Log.enableVerboseLogging = true
        
        #logTrace("This is a trace message using the #logTrace macro")
        #logDebug("This is a trace message using the #logDebug macro")
        #logInfo("This is an info message using the #logInfo macro")
        #logWarning("This is a warning using the #logWarning macro")
        
        Log.enableVerboseLogging = false
        
        #logNotice("This is a notice using the #logNotice macro")
        #logError("This is an error using the #logError macro")
        #logCritical("This is a critial using the #logCritical macro")
        #logFault("This is a fault using the #logFault macro")
    }
}
