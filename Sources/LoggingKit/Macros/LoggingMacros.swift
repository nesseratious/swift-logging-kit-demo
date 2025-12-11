//
//  LoggingMacros.swift
//  LoggingKit
//
//  Created by Denis Esie on 27.11.2025.
//

import Foundation
import OSLog

/// Macro for logging trace-level messages.
/// Expands to: `Self.trace(message, #file, #function)`
@freestanding(expression)
public macro logTrace(_ message: OSLogMessage, logger: Loggable.Type? = nil) -> Void = #externalMacro(module: "LoggingKitMacros", type: "LogTraceMacro")

/// Macro for logging debug-level messages.
/// Expands to: `Self.debug(message, #file, #function)`
@freestanding(expression)
public macro logDebug(_ message: OSLogMessage, logger: Loggable.Type? = nil) -> Void = #externalMacro(module: "LoggingKitMacros", type: "LogDebugMacro")

/// Macro for logging info-level messages.
/// Expands to: `Self.info(message, #file, #function)`
@freestanding(expression)
public macro logInfo(_ message: OSLogMessage, logger: Loggable.Type? = nil) -> Void = #externalMacro(module: "LoggingKitMacros", type: "LogInfoMacro")

/// Macro for logging user event messages.
/// Expands to: `Self.userEvent(message, #file, #function)`
@freestanding(expression)
public macro logUserEvent(_ message: OSLogMessage, logger: Loggable.Type? = nil) -> Void = #externalMacro(module: "LoggingKitMacros", type: "LogUserEventMacro")

/// Macro for logging performance-related messages.
/// Expands to: `Self.performance(message, #file, #function)`
@freestanding(expression)
public macro logPerformance(_ message: OSLogMessage, logger: Loggable.Type? = nil) -> Void = #externalMacro(module: "LoggingKitMacros", type: "LogPerformanceMacro")

/// Macro for logging success messages.
/// Expands to: `Self.success(message, #file, #function)`
@freestanding(expression)
public macro logSuccess(_ message: OSLogMessage, logger: Loggable.Type? = nil) -> Void = #externalMacro(module: "LoggingKitMacros", type: "LogSuccessMacro")

/// Macro for logging notice-level messages.
/// Expands to: `Self.notice(message, #file, #function)`
@freestanding(expression)
public macro logNotice(_ message: OSLogMessage, logger: Loggable.Type? = nil) -> Void = #externalMacro(module: "LoggingKitMacros", type: "LogNoticeMacro")

/// Macro for logging warning-level messages.
/// Expands to: `Self.warning(message, #file, #function)`
@freestanding(expression)
public macro logWarning(_ message: OSLogMessage, logger: Loggable.Type? = nil) -> Void = #externalMacro(module: "LoggingKitMacros", type: "LogWarningMacro")

/// Macro for logging error-level messages.
/// Expands to: `Self.error(message, #file, #function)`
@freestanding(expression)
public macro logError(_ message: OSLogMessage, logger: Loggable.Type? = nil) -> Void = #externalMacro(module: "LoggingKitMacros", type: "LogErrorMacro")

/// Macro for logging critical-level messages.
/// Expands to: `Self.critical(message, #file, #function)`
@freestanding(expression)
public macro logCritical(_ message: OSLogMessage, logger: Loggable.Type? = nil) -> Void = #externalMacro(module: "LoggingKitMacros", type: "LogCriticalMacro")

/// Macro for logging fault-level messages.
/// Expands to: `Self.fault(message, #file, #function)`
@freestanding(expression)
public macro logFault(_ message: OSLogMessage, logger: Loggable.Type? = nil) -> Void = #externalMacro(module: "LoggingKitMacros", type: "LogFaultMacro")

