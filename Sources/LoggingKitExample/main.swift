//
//  main.swift
//  LoggingKitExample
//
//  Created by Denis Esie on 27.11.2025.
//

import Foundation
import LoggingKit

struct ExampleLogger: Loggable {
    static let subsystem = "Example"
    
    // Demonstrate using macros within a type context
    func demonstrateMacros(foo: Bool) {
        #logTrace("This is a trace message using the #logTrace macro \("CARD NUMBER: 1234456677", privacy: .sensitive)")
        #logDebug("This is a trace message using the #logDebug macro")
        #logInfo("This is an info message using the #logInfo macro")
        #logUserEvent("This is a user event message using the \("#logUserEvent macro", privacy: .public)")
        #logPerformance("This is a performance message using the #logPerformance macro")
        #logSuccess("This is an success message using the #logSuccess macro")
        #logWarning("This is a warning using the #logWarning macro")
        #logNotice("This is a notice using the #logNotice macro")
        #logError("This is an error using the #logError macro")
        #logCritical("This is a critial using the #logCritical macro")
        #logFault("This is a fault using the #logFault macro")
        
        // Using macros with a custom logger instance
        #logInfo("This info message uses a custom logger", logger: ExampleLogger.self)
        #logWarning("This warning uses a custom logger", logger: ExampleLogger.self)
        #logError("This error uses a custom logger", logger: ExampleLogger.self)
        
        Log.saveCurrentSession()
    }
}

Log.logPath = .absolute("/Users/denisesie/dx-modules/swift-logging-kit/ExampleLogs")
Log.defaultLogFileName = "Log"
Log.fileAppendingType = .appendToExistingLogFile
Log.enableLiveLogging = false
Log.enableVerboseLogging = false
//Log.logLevel = Log.Level.Trace

//OSLogMessageExample()
//InjectedLoggerExample()
//TimelineRenderer().render()
//FileLoggingDemo().run()
//ExampleFunctionLogger().run()
VerboseLogger().run()

//ExampleLogger().demonstrateMacros(foo: true)

Log.saveCurrentSession()
