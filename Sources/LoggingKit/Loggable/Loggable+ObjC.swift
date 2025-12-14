//
//  ObjC.swift
//  LoggingKit
//
//  Created by Denis Esie on 27.11.2025.
//

import Foundation

#if os(macOS) || os(tvOS) || os(watchOS) || os(iOS) || os(visionOS)

@objc
extension NSObject {
    
    private struct InternalLogger<NSObject>: Loggable {
        static var subsystem: String {
            return "\(self.self)"
        }
    }
    
    /// Logs a trace-level message. Only collected if `Log.logLevel` allows it.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logTrace(_ message: String, _ file: String = #file, _ function: String = #function) {
        InternalLogger<Self>.logTrace(message, file, function)
    }
    
    /// Logs a debug-level message. Only collected if `Log.logLevel` allows it.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logDebug( _ message: String, _ file: String = #file, _ function: String = #function) {
        InternalLogger<Self>.logDebug(message, file, function)
    }
    
    /// Logs an info-level message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logInfo(_ message: String, _ file: String = #file, _ function: String = #function) {
        InternalLogger<Self>.logInfo(message, file, function)
    }
    
    /// Logs a user event message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logUserEvent(_ message: String, _ file: String = #file, _ function: String = #function) {
        InternalLogger<Self>.logUserEvent(message, file, function)
    }
    
    /// Logs a performance-related message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logPerformance(_ message: String, _ file: String = #file, _ function: String = #function) {
        InternalLogger<Self>.logPerformance(message, file, function)
    }
    
    /// Logs a success message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logSuccess(_ message: String, _ file: String = #file, _ function: String = #function) {
        InternalLogger<Self>.logSuccess(message, file, function)
    }
    
    /// Logs a notice-level message.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logNotice(_ message: String, _ file: String = #file, _ function: String = #function) {
        InternalLogger<Self>.logNotice(message, file, function)
    }
    
    /// Logs a warning-level message. Triggers the registered warning hook if set.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logWarning(_ message: String, _ file: String = #file, _ function: String = #function) {
        InternalLogger<Self>.logWarning(message, file, function)
    }
    
    /// Logs an error-level message. Triggers the registered error hook if set.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logError( _ message: String, _ file: String = #file, _ function: String = #function) {
        InternalLogger<Self>.logError(message, file, function)
    }
    
    /// Logs a critical-level message. Triggers the registered critical hook if set.
    /// In DEBUG builds, this will also call `fatalError`.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logCritical( _ message: String, _ file: String = #file, _ function: String = #function) {
        InternalLogger<Self>.logCritical(message, file, function)
    }
    
    /// Logs a fault-level message and terminates the program with `fatalError`.
    /// Triggers the registered critical hook if set.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The source file (automatically captured).
    ///   - function: The function name (automatically captured).
    public static func logFault(_ message: String, _ file: String = #file, _ function: String = #function) {
        InternalLogger<Self>.logFault(message, file, function)
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

#endif // os(macOS) || os(tvOS) || os(watchOS) || os(iOS) || os(visionOS)
