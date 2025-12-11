//
//  AtomicLogBuffer.swift
//  LoggingKit
//
//  Created by Denis Esie on 29.11.2025.
//

import Atomics
import Foundation

/// Thread-safe, lock-free circular buffer for log storage.
/// Optimized for high-throughput writes with minimal memory footprint.
@usableFromInline
final class AtomicLogBuffer: @unchecked Sendable {
    /// Maximum number of log entries to store
    @usableFromInline
    let capacity: Int
    
    /// Contiguous memory buffer for cache efficiency
    @usableFromInline
    let buffer: UnsafeMutablePointer<String?>
    
    /// Atomic write index for lock-free concurrent appends
    @usableFromInline
    let writeIndex: ManagedAtomic<Int>
    
    /// Atomic count of stored entries (capped at capacity)
    @usableFromInline
    let count: ManagedAtomic<Int>
    
    /// Initialize buffer with specified capacity
    /// - Parameter capacity: Maximum number of log entries (default: 10,000)
    @inlinable
    init(capacity: Int) {
        precondition(capacity > 0, "Capacity must be greater than 0")
        self.capacity = capacity
        self.buffer = UnsafeMutablePointer<String?>.allocate(capacity: capacity)
        self.buffer.initialize(repeating: nil, count: capacity)
        self.writeIndex = ManagedAtomic<Int>(0)
        self.count = ManagedAtomic<Int>(0)
    }
    
    /// Appends a log string to the buffer in a thread-safe, lock-free manner.
    /// Uses atomic compare-exchange for coordination between concurrent writers.
    /// - Parameter log: The log string to append
    @inlinable
    @inline(__always)
    func append(_ log: String) {
        // Atomically increment write index and wrap around
        let index = writeIndex.loadThenWrappingIncrement(ordering: .relaxed)
        let actualIndex = index % capacity
        
        // Store the log at the computed index
        buffer[actualIndex] = log
        
        // Update count atomically, capping at capacity
        let oldCount = count.load(ordering: .relaxed)
        if oldCount < capacity {
            _ = count.compareExchange(
                expected: oldCount,
                desired: min(oldCount &+ 1, capacity),
                ordering: .relaxed
            )
        }
    }
    
    /// Returns all stored logs as a single newline-separated string.
    /// This operation reads the buffer and should be used sparingly in write-heavy scenarios.
    /// - Returns: All logs joined with newlines
    @inlinable
    func converged() -> String {
        let currentCount = count.load(ordering: .acquiring)
        guard currentCount > 0 else { return "" }
        
        let currentWriteIndex = writeIndex.load(ordering: .acquiring)
        var logs: [String] = []
        logs.reserveCapacity(currentCount)
        
        // If buffer isn't full yet, read from start to current position
        if currentCount < capacity {
            for i in 0..<currentCount {
                if let log = buffer[i] {
                    logs.append(log)
                }
            }
        } else {
            // Buffer is full - read from oldest to newest (circular)
            let startIndex = currentWriteIndex % capacity
            for offset in 0..<capacity {
                let index = (startIndex &+ offset) % capacity
                if let log = buffer[index] {
                    logs.append(log)
                }
            }
        }
        
        return logs.joined(separator: "\n")
    }
    
    /// Clears all content from the buffer in a thread-safe manner.
    /// Resets the write index and count, and clears all buffer entries.
    @inlinable
    func clear() {
        writeIndex.store(0, ordering: .releasing)
        count.store(0, ordering: .releasing)
        
        // Clear all buffer entries
        for i in 0..<capacity {
            buffer[i] = nil
        }
    }
    
    /// Clean up allocated memory
    deinit {
        buffer.deinitialize(count: capacity)
        buffer.deallocate()
    }
}
