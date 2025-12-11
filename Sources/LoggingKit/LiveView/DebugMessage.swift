//
//  DebugMessage.swift
//  LoggingKit
//
//  Created by Denis Esie on 29.11.2025.
//

import Foundation
import SwiftUI

extension Log {
    
    /// Represents a single debug log message with metadata.
    @frozen public struct DebugMessage: Identifiable, Hashable, Sendable {
        
        /// The subsystem that generated this log message.
        public let subsystem: String
        
        /// The log message text.
        public let message: String
        
        /// The severity level of this log message.
        public let level: Level
        
        /// The timestamp when this log message was created.
        public let timestamp: Date
        
        /// Unique identifier based on the timestamp.
        public var id: Date { timestamp }
        
        @inlinable
        init(subsystem: String, message: String, level: Level, timestamp: Date) {
            self.subsystem = subsystem
            self.message = message
            self.level = level
            self.timestamp = timestamp
        }
        
        @inlinable
        public static func trace(subsystem: String, message: String) -> Self {
            return DebugMessage(subsystem: subsystem, message: message, level: .trace, timestamp: Date())
        }
        
        @inlinable
        public static func debug(subsystem: String, message: String) -> Self {
            return DebugMessage(subsystem: subsystem, message: message, level: .debug, timestamp: Date())
        }
        
        @inlinable
        public static func info(subsystem: String, message: String) -> Self {
            return DebugMessage(subsystem: subsystem, message: message, level: .info, timestamp: Date())
        }
        
        @inlinable
        public static func userEvent(subsystem: String, message: String) -> Self {
            return DebugMessage(subsystem: subsystem, message: message, level: .userEvent, timestamp: Date())
        }
        
        @inlinable
        public static func performance(subsystem: String, message: String) -> Self {
            return DebugMessage(subsystem: subsystem, message: message, level: .performance, timestamp: Date())
        }
        
        @inlinable
        public static func success(subsystem: String, message: String) -> Self {
            return DebugMessage(subsystem: subsystem, message: message, level: .success, timestamp: Date())
        }
        
        @inlinable
        public static func notice(subsystem: String, message: String) -> Self {
            return DebugMessage(subsystem: subsystem, message: message, level: .notice, timestamp: Date())
        }
        
        @inlinable
        public static func warning(subsystem: String, message: String) -> Self {
            return DebugMessage(subsystem: subsystem, message: message, level: .warning, timestamp: Date())
        }
        
        @inlinable
        public static func error(subsystem: String, message: String) -> Self {
            return DebugMessage(subsystem: subsystem, message: message, level: .error, timestamp: Date())
        }
        
        @inlinable
        public static func critical(subsystem: String, message: String) -> Self {
            return DebugMessage(subsystem: subsystem, message: message, level: .critical, timestamp: Date())
        }
        
        @inlinable
        public static func fault(subsystem: String, message: String) -> Self {
            return DebugMessage(subsystem: subsystem, message: message, level: .fault, timestamp: Date())
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(timestamp)
        }
        
        /// Log severity levels, ordered from least to most severe.
        @frozen public enum Level: Int, Sendable, CaseIterable {
            /// Trace-level logging for detailed diagnostic information.
            case trace = 0
            /// Debug-level logging for development and troubleshooting.
            case debug
            /// Info-level logging for general informational messages.
            case info
            /// User event logging for tracking user interactions.
            case userEvent
            /// Performance logging for performance-related metrics.
            case performance
            /// Success logging for successful operations.
            case success
            /// Notice-level logging for important but non-critical information.
            case notice
            /// Warning-level logging for potentially problematic situations.
            case warning
            /// Error-level logging for error conditions.
            case error
            /// Critical-level logging for critical errors that may cause failures.
            case critical
            /// Fault-level logging for system-level faults that terminate execution.
            case fault
        }
        
        public var image: Image {
            switch level {
            case .trace:
                return Image(systemName: "stethoscope")
            case .debug:
                return Image(systemName: "stethoscope")
            case .info:
                return Image(systemName: "info")
            case .userEvent:
                return Image(systemName: "person.fill")
            case .performance:
                return Image(systemName: "cpu.fill")
            case .success:
                return Image(systemName: "info")
            case .notice:
                return Image(systemName: "bell.fill")
            case .warning:
                return Image(systemName: "exclamationmark.2")
            case .error:
                return Image(systemName: "exclamationmark.2")
            case .critical:
                return Image(systemName: "exclamationmark.3")
            case .fault:
                return Image(systemName: "exclamationmark.3")
            }
        }
        
        public var imageColor: Color {
            switch level {
            case .trace, .debug:
                return .gray
            case .info, .userEvent, .performance, .success:
                return .blue
            case .notice:
                return .gray
            case .warning:
                return .yellow
            case .error:
                return .yellow
            case .critical:
                return .red
            case .fault:
                return .red
            }
        }
        
        public var imageSize: CGSize {
            switch level {
            case .trace, .debug:
                return CGSize(width: 14.0, height: 12.0)
            case .info:
                return CGSize(width: 10.0, height: 12.0)
            case .userEvent:
                return CGSize(width: 12.0, height: 12.0)
            case .performance:
                return CGSize(width: 12.0, height: 12.0)
            case .success:
                return CGSize(width: 10.0, height: 12.0)
            case .notice:
                return CGSize(width: 12.0, height: 12.0)
            case .warning, .error:
                return CGSize(width: 10.0, height: 12.0)
            case .critical, .fault:
                return CGSize(width: 14.0, height: 12.0)
            }
        }
        
        public var typeString: String {
            switch level {
            case .trace:
                return "Trace"
            case .debug:
                return "Debug"
            case .info:
                return "Info"
            case .performance:
                return "Performance"
            case .userEvent:
                return "UserEvent"
            case .success:
                return "Success"
            case .notice:
                return "Notice"
            case .warning:
                return "Warning"
            case .error:
                return "Error"
            case .critical:
                return "Critical"
            case .fault:
                return "Fault"
            }
        }
        
        public var tintColor: Color {
            switch level {
            case .trace, .debug, .info, .userEvent:
                return .clear
            case .performance:
                return .clear.opacity(0.5)
            case .success:
                return .green.opacity(0.5)
            case .notice:
                return .indigo.opacity(0.5)
            case .warning:
                return .yellow.opacity(0.5)
            case .error:
                return .yellow.opacity(0.5)
            case .critical:
                return .red.opacity(0.5)
            case .fault:
                return .red.opacity(0.5)
            }
        }
    }
}
