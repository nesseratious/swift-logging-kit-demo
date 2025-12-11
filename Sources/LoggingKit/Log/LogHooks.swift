//
//  LogHooks.swift
//  LoggingKit
//
//  Created by Denis Esie on 29.11.2025.
//

import Foundation

extension Log {
    
    /// Optional hook called for all log messages.
    /// - Parameter message: The log message string.
    @usableFromInline
    nonisolated(unsafe) static var messageHook: ((String) -> Void)?
    
    /// Optional hook called for trace-level log messages.
    /// - Parameters:
    ///   - subsystem: The subsystem that generated the trace message.
    ///   - message: The trace message.
    @usableFromInline
    nonisolated(unsafe) static var traceHook: ((String, String) -> Void)?
    
    /// Optional hook called for debug-level log messages.
    /// - Parameters:
    ///   - subsystem: The subsystem that generated the debug message.
    ///   - message: The debug message.
    @usableFromInline
    nonisolated(unsafe) static var debugHook: ((String, String) -> Void)?
    
    /// Optional hook called for info-level log messages.
    /// - Parameters:
    ///   - subsystem: The subsystem that generated the info message.
    ///   - message: The info message.
    @usableFromInline
    nonisolated(unsafe) static var infoHook: ((String, String) -> Void)?
    
    /// Optional hook called for user event log messages.
    /// - Parameters:
    ///   - subsystem: The subsystem that generated the user event message.
    ///   - message: The user event message.
    @usableFromInline
    nonisolated(unsafe) static var userEventHook: ((String, String) -> Void)?
    
    /// Optional hook called for performance-related log messages.
    /// - Parameters:
    ///   - subsystem: The subsystem that generated the performance message.
    ///   - message: The performance message.
    @usableFromInline
    nonisolated(unsafe) static var performanceHook: ((String, String) -> Void)?
    
    /// Optional hook called for success log messages.
    /// - Parameters:
    ///   - subsystem: The subsystem that generated the success message.
    ///   - message: The success message.
    @usableFromInline
    nonisolated(unsafe) static var successHook: ((String, String) -> Void)?
    
    /// Optional hook called for notice-level log messages.
    /// - Parameters:
    ///   - subsystem: The subsystem that generated the notice message.
    ///   - message: The notice message.
    @usableFromInline
    nonisolated(unsafe) static var noticeHook: ((String, String) -> Void)?
    
    /// Optional hook called for warning-level log messages.
    /// - Parameters:
    ///   - subsystem: The subsystem that generated the warning.
    ///   - message: The warning message.
    @usableFromInline
    nonisolated(unsafe) static var warningHook: ((String, String) -> Void)?
    
    /// Optional hook called for error-level log messages.
    /// - Parameters:
    ///   - subsystem: The subsystem that generated the error.
    ///   - message: The error message.
    @usableFromInline
    nonisolated(unsafe) static var errorHook: ((String, String) -> Void)?
    
    /// Optional hook called for critical-level log messages.
    /// - Parameters:
    ///   - subsystem: The subsystem that generated the critical message.
    ///   - message: The critical message.
    @usableFromInline
    nonisolated(unsafe) static var criticalHook: ((String, String) -> Void)?
    
    /// Optional hook called for critical-level log messages.
    /// - Parameters:
    ///   - subsystem: The subsystem that generated the critical message.
    ///   - message: The critical message.
    @usableFromInline
    nonisolated(unsafe) static var faultHook: ((String, String) -> Void)?
    
    /// Registers a hook for all log messages.
    /// - Parameter hook: Hook called for all log messages. Receives the message string.
    public static func registerMessageHook(_ hook: ((String) -> Void)?) {
        messageHook = hook
    }
    
    /// Registers a hook for trace-level log messages.
    /// - Parameter hook: Hook called for trace-level messages. Receives subsystem and message.
    public static func registerTraceHook(_ hook: ((String, String) -> Void)?) {
        traceHook = hook
    }
    
    /// Registers a hook for debug-level log messages.
    /// - Parameter hook: Hook called for debug-level messages. Receives subsystem and message.
    public static func registerDebugHook(_ hook: ((String, String) -> Void)?) {
        debugHook = hook
    }
    
    /// Registers a hook for info-level log messages.
    /// - Parameter hook: Hook called for info-level messages. Receives subsystem and message.
    public static func registerInfoHook(_ hook: ((String, String) -> Void)?) {
        infoHook = hook
    }
    
    /// Registers a hook for user event log messages.
    /// - Parameter hook: Hook called for user event messages. Receives subsystem and message.
    public static func registerUserEventHook(_ hook: ((String, String) -> Void)?) {
        userEventHook = hook
    }
    
    /// Registers a hook for performance-related log messages.
    /// - Parameter hook: Hook called for performance messages. Receives subsystem and message.
    public static func registerPerformanceHook(_ hook: ((String, String) -> Void)?) {
        performanceHook = hook
    }
    
    /// Registers a hook for success log messages.
    /// - Parameter hook: Hook called for success messages. Receives subsystem and message.
    public static func registerSuccessHook(_ hook: ((String, String) -> Void)?) {
        successHook = hook
    }
    
    /// Registers a hook for notice-level log messages.
    /// - Parameter hook: Hook called for notice-level messages. Receives subsystem and message.
    public static func registerNoticeHook(_ hook: ((String, String) -> Void)?) {
        noticeHook = hook
    }
    
    /// Registers a hook for warning-level log messages.
    /// - Parameter hook: Hook called for warning-level messages. Receives subsystem and message.
    public static func registerWarningHook(_ hook: ((String, String) -> Void)?) {
        warningHook = hook
    }
    
    /// Registers a hook for error-level log messages.
    /// - Parameter hook: Hook called for error-level messages. Receives subsystem and message.
    public static func registerErrorHook(_ hook: ((String, String) -> Void)?) {
        errorHook = hook
    }
    
    /// Registers a hook for critical-level log messages.
    /// - Parameter hook: Hook called for critical-level messages. Receives subsystem and message.
    public static func registerCriticalHook(_ hook: ((String, String) -> Void)?) {
        criticalHook = hook
    }
    
    /// Registers a hook for critical-level log messages.
    /// - Parameter hook: Hook called for critical-level messages. Receives subsystem and message.
    public static func registerFaultHook(_ hook: ((String, String) -> Void)?) {
        criticalHook = hook
    }
}

extension Log {
    
    /// Public helper to call the message hook.
    @inlinable
    public static func callMessageHook(_ message: String) {
        messageHook?(message)
    }
    
    /// Public helper to call the trace hook.
    @inlinable
    public static func callTraceHook(_ subsystem: String, _ message: String) {
        traceHook?(subsystem, message)
    }
    
    /// Public helper to call the debug hook.
    @inlinable
    public static func callDebugHook(_ subsystem: String, _ message: String) {
        debugHook?(subsystem, message)
    }
    
    /// Public helper to call the info hook.
    @inlinable
    public static func callInfoHook(_ subsystem: String, _ message: String) {
        infoHook?(subsystem, message)
    }
    
    /// Public helper to call the user event hook.
    @inlinable
    public static func callUserEventHook(_ subsystem: String, _ message: String) {
        userEventHook?(subsystem, message)
    }
    
    /// Public helper to call the performance hook.
    @inlinable
    public static func callPerformanceHook(_ subsystem: String, _ message: String) {
        performanceHook?(subsystem, message)
    }
    
    /// Public helper to call the success hook.
    @inlinable
    public static func callSuccessHook(_ subsystem: String, _ message: String) {
        successHook?(subsystem, message)
    }
    
    /// Public helper to call the notice hook.
    @inlinable
    public static func callNoticeHook(_ subsystem: String, _ message: String) {
        noticeHook?(subsystem, message)
    }
    
    /// Public helper to call the warning hook.
    @inlinable
    public static func callWarningHook(_ subsystem: String, _ message: String) {
        warningHook?(subsystem, message)
    }
    
    /// Public helper to call the error hook.
    @inlinable
    public static func callErrorHook(_ subsystem: String, _ message: String) {
        errorHook?(subsystem, message)
    }
    
    /// Public helper to call the critical hook.
    @inlinable
    public static func callCriticalHook(_ subsystem: String, _ message: String) {
        criticalHook?(subsystem, message)
    }
    
    /// Public helper to call the critical hook.
    @inlinable
    public static func callFaultHook(_ subsystem: String, _ message: String) {
        faultHook?(subsystem, message)
    }
}
