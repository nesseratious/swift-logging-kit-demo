//
//  5.swift
//  LoggingKit
//
//  Created by Denis Esie on 11.12.2025.
//

import LoggingKit

struct FileLoggingDemo {
    func run() {
        Log.defaultLogFileName = "LoggingDemoFile"
        Log.fileAppendingType = .appendCreatingNewFileIfLimitIsReached
        Log.fileLimit = 200
        
        for i in 1...100 {
            #logInfo("Hello, world! \(i)")
        }
    }
}
