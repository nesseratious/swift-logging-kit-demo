//
//  3.swift
//  LoggingKit
//
//  Created by Denis Esie on 11.12.2025.
//

import LoggingKit

class TimelineRenderer: Loggable {
    static let subsystem = "Timeline"
    
    func render() {
        Log.logLevel = Log.Level.Trace
//        Log.logLevel = Log.Level.Debug
        
        #logTrace("Entering render function, initializing timeline components")
        for i in 0...10 {
            let renderer = DayRenderer(day: i)
            renderer.render()
        }
        #logDebug("Timeline data loaded: 42 events found")
        
        #logInfo("Rendering timeline view for user dashboard")
        #logWarning("Timeline cache is nearly full, consider clearing old entries")
        #logCritical("Timeline renderer failed: memory allocation failed")
        #logFault("System fault detected: divide by zero, universe is collapsing")
    }
}

struct DayRenderer: Loggable {
    static let subsystem = "Day Renderer"
    
    let day: Int
    
    func render() {
        #logTrace("Rendering day with index \(day)")
    }
}
