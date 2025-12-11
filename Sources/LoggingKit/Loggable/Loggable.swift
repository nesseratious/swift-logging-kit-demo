//
//  Loggable.swift
//  LoggingKit
//
//  Created by Denis Esie on 06.12.2023.
//

import Foundation

/// Protocol that enables logging functionality for conforming types.
/// Types conforming to this protocol can use all logging methods (trace, debug, info, etc.).
public protocol Loggable: LogFunctionsProtocol {
    
    /// The subsystem identifier used for categorizing logs.
    static var subsystem: String { get }
    
    /// The file where to save this logs
    static var file: String { get }
}

extension Loggable {
    public static var subsystem: String {
        return Log.defaultSubsystem
    }
    
    public static var file: String {
        return Log.defaultLogFileName
    }
}
