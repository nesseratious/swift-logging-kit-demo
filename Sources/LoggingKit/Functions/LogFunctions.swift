//
//  LogFunctions.swift
//  LoggingKit
//
//  Created by Denis Esie on 27.11.2025.
//

import Foundation

public protocol LogFunctionsProtocol {
    static var subsystem: String { get }
}

extension LogFunctionsProtocol {
    
    /// Logs a trace-level message. Only collected if `Log.logLevel` allows it.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logTrace(_ message: String, _ file: String = #file, _ function: String = #function) {
        guard Log.Level.Trace >= Log.logLevel else { return }
        
        let fileName = Log.fileName(from: file)
        let category = "\(fileName).\(function)"
        Logger(subsystem: subsystem, category: category).trace("\(message)")
        Log.History.add("TRACE  \(Log.dateFormatter.string(from: Date())) [\(subsystem)] [\(category)] \(message)")
        if Log.enableLiveLogging { LiveLogHistory.shared.add(.trace(subsystem: subsystem, message: message)) }
        
        Log.callMessageHook(message)
        Log.callTraceHook(subsystem, message)
    }
    
    /// Logs a debug-level message. Only collected if `Log.logLevel` allows it.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logDebug( _ message: String, _ file: String = #file, _ function: String = #function) {
        guard Log.Level.Debug >= Log.logLevel else { return }
        
        let fileName = Log.fileName(from: file)
        let category = "\(fileName).\(function)"
        Logger(subsystem: subsystem, category: category).debug("\(message)")
        Log.History.add("DEBUG  \(Log.dateFormatter.string(from: Date())) [\(subsystem)] \(category)] \(message)")
        if Log.enableLiveLogging { LiveLogHistory.shared.add(.debug(subsystem: subsystem, message: message)) }
        
        Log.callMessageHook(message)
        Log.callDebugHook(subsystem, message)
    }
    
    /// Logs an info-level message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logInfo(_ message: String, _ file: String = #file, _ function: String = #function) {
        guard Log.Level.Info >= Log.logLevel else { return }
        
        let fileName = Log.fileName(from: file)
        let category = "\(fileName).\(function)"
        Logger(subsystem: subsystem, category: category).info("\(message)")
        Log.History.add("INFO   \(Log.dateFormatter.string(from: Date())) [\(subsystem)] [\(category)] \(message)")
        if Log.enableLiveLogging { LiveLogHistory.shared.add(.info(subsystem: subsystem, message: message)) }
        
        Log.callMessageHook(message)
        Log.callInfoHook(subsystem, message)
    }
    
    /// Logs a user event message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logUserEvent(_ message: String, _ file: String = #file, _ function: String = #function) {
        guard Log.Level.Info >= Log.logLevel else { return }
        
        let fileName = Log.fileName(from: file)
        let category = "\(fileName).\(function)"
        Logger(subsystem: subsystem, category: category).info("\(message)")
        Log.History.add("EVENT  \(Log.dateFormatter.string(from: Date())) [\(subsystem)] [\(category)] \(message)")
        if Log.enableLiveLogging { LiveLogHistory.shared.add(.userEvent(subsystem: subsystem, message: message)) }
        
        Log.callMessageHook(message)
        Log.callUserEventHook(subsystem, message)
    }
    
    /// Logs a performance-related message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logPerformance(_ message: String, _ file: String = #file, _ function: String = #function) {
        guard Log.Level.Info >= Log.logLevel else { return }
        
        let fileName = Log.fileName(from: file)
        let category = "\(fileName).\(function)"
        Logger(subsystem: subsystem, category: category).info("\(message)")
        Log.History.add("PERFR  \(Log.dateFormatter.string(from: Date())) [\(subsystem)] [\(category)] \(message)")
        if Log.enableLiveLogging { LiveLogHistory.shared.add(.performance(subsystem: subsystem, message: message)) }
        
        Log.callMessageHook(message)
        Log.callPerformanceHook(subsystem, message)
    }
    
    /// Logs a success message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logSuccess(_ message: String, _ file: String = #file, _ function: String = #function) {
        guard Log.Level.Info >= Log.logLevel else { return }
        
        let fileName = Log.fileName(from: file)
        let category = "\(fileName).\(function)"
        Logger(subsystem: subsystem, category: category).info("\(message)")
        Log.History.add("SCCSS  \(Log.dateFormatter.string(from: Date())) [\(subsystem)] [\(category)] \(message)")
        if Log.enableLiveLogging { LiveLogHistory.shared.add(.success(subsystem: subsystem, message: message)) }
        
        Log.callMessageHook(message)
        Log.callSuccessHook(subsystem, message)
    }
    
    /// Logs a notice-level message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logNotice(_ message: String, _ file: String = #file, _ function: String = #function) {
        guard Log.Level.Notice >= Log.logLevel else { return }
        
        let fileName = Log.fileName(from: file)
        let category = "\(fileName).\(function)"
        Logger(subsystem: subsystem, category: category).notice("\(message)")
        Log.History.add("NOTICE \(Log.dateFormatter.string(from: Date()))] [\(subsystem)] [\(category)] \(message)")
        if Log.enableLiveLogging { LiveLogHistory.shared.add(.notice(subsystem: subsystem, message: message)) }
        
        Log.callMessageHook(message)
        Log.callNoticeHook(subsystem, message)
    }
    
    /// Logs a warning-level message. Triggers the registered warning hook if set.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logWarning(_ message: String, _ file: String = #file, _ function: String = #function) {
        guard Log.Level.Warning >= Log.logLevel else { return }
        
        let fileName = Log.fileName(from: file)
        let category = "\(fileName).\(function)"
        Logger(subsystem: subsystem, category: category).warning("\(message)")
        Log.History.add("WARNG  \(Log.dateFormatter.string(from: Date())) [\(subsystem)] [\(category)] \(message)")
        if Log.enableLiveLogging { LiveLogHistory.shared.add(.warning(subsystem: subsystem, message: message)) }
        
        Log.callMessageHook(message)
        Log.callWarningHook(subsystem, message)
    }
    
    /// Logs an error-level message. Triggers the registered error hook if set.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logError( _ message: String, _ file: String = #file, _ function: String = #function) {
        guard Log.Level.Error >= Log.logLevel else { return }
        
        let fileName = Log.fileName(from: file)
        let category = "\(fileName).\(function)"
        Logger(subsystem: subsystem, category: category).error("\(message)")
        Log.History.add("ERROR  \(Log.dateFormatter.string(from: Date())) [\(subsystem)] [\(category)] \(message)")
        if Log.enableLiveLogging { LiveLogHistory.shared.add(.error(subsystem: subsystem, message: message)) }
        
        Log.callMessageHook(message)
        Log.callErrorHook(subsystem, message)
    }
    
    /// Logs a critical-level message. Triggers the registered critical hook if set.
    /// In DEBUG builds, this will also call `fatalError`.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logCritical( _ message: String, _ file: String = #file, _ function: String = #function) {
        guard Log.Level.Critical >= Log.logLevel else { return }
        
        let fileName = Log.fileName(from: file)
        let category = "\(fileName).\(function)"
        Logger(subsystem: subsystem, category: category).critical("\(message)")
        Log.History.add("CRITCL \(Log.dateFormatter.string(from: Date())) [\(subsystem)] [\(category)] \(message)")
        if Log.enableLiveLogging { LiveLogHistory.shared.add(.critical(subsystem: subsystem, message: message)) }
        
        Log.callMessageHook(message)
        Log.callCriticalHook(subsystem, message)
    }
    
    /// Logs a fault-level message and terminates the program with `fatalError`.
    /// Triggers the registered critical hook if set.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logFault(_ message: String, _ file: String = #file, _ function: String = #function) {
        guard Log.Level.Fault >= Log.logLevel else { return }
        
        let fileName = Log.fileName(from: file)
        let category = "\(fileName).\(function)"
        Logger(subsystem: subsystem, category: category).fault("\(message)")
        Log.History.add("FAULT  \(Log.dateFormatter.string(from: Date())) [\(subsystem)] [\(category)] \(message)")
        if Log.enableLiveLogging { LiveLogHistory.shared.add(.fault(subsystem: subsystem, message: message)) }
        
        Log.callMessageHook(message)
        Log.callCriticalHook(subsystem, message)
    }
    
    public func logTrace(_ message: String, _ file: String = #file, _ function: String = #function) {
        Self.logTrace(message, file, function)
    }
    
    public func logDebug(_ message: String, _ file: String = #file, _ function: String = #function) {
        Self.logDebug(message, file, function)
    }
    
    public func logInfo(_ message: String, _ file: String = #file, _ function: String = #function) {
        Self.logInfo(message, file, function)
    }
    
    public func logUserEvent(_ message: String, _ file: String = #file, _ function: String = #function) {
        Self.logUserEvent(message, file, function)
    }
    
    public func logPerformance(_ message: String, _ file: String = #file, _ function: String = #function) {
        Self.logPerformance(message, file, function)
    }
    
    public func logSuccess(_ message: String, _ file: String = #file, _ function: String = #function) {
        Self.logSuccess(message, file, function)
    }
    
    public func logNotice(_ message: String, _ file: String = #file, _ function: String = #function) {
        Self.logNotice(message, file, function)
    }
    
    public func logWarning(_ message: String, _ file: String = #file, _ function: String = #function) {
        Self.logWarning(message, file, function)
    }
    
    public func logError(_ message: String, _ file: String = #file, _ function: String = #function) {
        Self.logError(message, file, function)
    }
    
    public func logCritical(_ message: String, _ file: String = #file, _ function: String = #function) {
        Self.logCritical(message, file, function)
    }
    
    public func logFault(_ message: String, _ file: String = #file, _ function: String = #function) {
        Self.logFault(message, file, function)
    }
}
