//
//  LogHistory.swift
//  LoggingKit
//
//  Created by Denis Esie on 27.11.2025.
//

import Foundation
import Atomics

extension Log {
    public enum History {
        
        public static var limitPerFile: Int {
            @inline(__always) get {
                Log.fileLimit
            }
        }
        
        /// Thread-safe log buffer stored in memory.
        @inline(__always)
        @usableFromInline
        static let current = AtomicLogBuffer(capacity: limitPerFile)
        
        @inline(__always)
        @inlinable
        nonisolated public static func add(_ log: String) {
            current.append(log)
            
            if current.count.load(ordering: .acquiring) == limitPerFile {
                Log.saveCurrentSession()
                current.clear()
            }
        }
        
        nonisolated public static func converged() -> String {
            return current.converged()
        }
    }
}
