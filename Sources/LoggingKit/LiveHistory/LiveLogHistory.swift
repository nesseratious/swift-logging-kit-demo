//
//  LiveLogHistory.swift
//  LoggingKit
//
//  Created by Denis Esie on 16.11.2025.
//

import Foundation
import SwiftUI

/// Observable object that maintains a history of debug log messages.
/// Used by SwiftUI views to display and filter logs.
public final class LiveLogHistory: ObservableObject {
    
    /// Shared singleton instance of LogHistory.
    nonisolated(unsafe) public static let shared = LiveLogHistory()
    
    /// Array of debug log messages. Published for SwiftUI observation
    @usableFromInline
    @Published var logs: [Log.DebugMessage] = []
    
    /// Recursive lock for thread-safe log operations.
    @usableFromInline
    let lock = NSRecursiveLock()
    
    /// Initializes a new LogHistory instance.
    public init() {}
    
    @inlinable
    public func add(_ log: Log.DebugMessage) {
        lock.lock()
        defer { lock.unlock() }
        
        if Thread.isMainThread {
            logs.append(log)
            trimLogsIfNeeded()
        } else {
            nonisolated(unsafe) let _self = self
            Task { @MainActor in
                _self.logs.append(log)
                _self.trimLogsIfNeeded()
            }
        }
    }
    
    /// Trims logs to the maximum count, keeping the most recent logs.
    /// This is called automatically after each log append operation.
    @inlinable
    func trimLogsIfNeeded() {
        let limit = Log.fileLimit
        guard limit > 0 && logs.count > limit else { return }
        let excessCount = logs.count &- limit
        logs.removeFirst(excessCount)
    }
}
