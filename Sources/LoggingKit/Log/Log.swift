//
//  Log.swift
//  LoggingKit
//
//  Created by Esie on 2/1/21.
//  Copyright © 2021 Denis Esie. All rights reserved.
//

import Foundation
@_exported import struct Foundation.Date

#if canImport(OSLog)
import OSLog
@_exported import struct OSLog.Logger
#else

#if os(Windows)
import WinSDK
#endif

// Stub Logger for platforms without OSLog (Windows)
public struct Logger {
    public let subsystem: String
    public let category: String
    
    public init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
    }
    
#if os(Windows)
    // Windows Console API color codes
    private enum ConsoleColor: WORD {
        case black = 0
        case darkBlue = 1
        case darkGreen = 2
        case darkCyan = 3
        case darkRed = 4
        case darkMagenta = 5
        case darkYellow = 6
        case gray = 7
        case darkGray = 8
        case blue = 9
        case green = 10
        case cyan = 11
        case red = 12
        case magenta = 13
        case yellow = 14
        case white = 15
    }
    
    nonisolated(unsafe) private static let consoleHandle: HANDLE? = {
        let handle = GetStdHandle(STD_OUTPUT_HANDLE)
        return handle != INVALID_HANDLE_VALUE ? handle : nil
    }()
    
    private static let originalAttributes: WORD? = {
        guard let handle = consoleHandle else { return nil }
        var info: CONSOLE_SCREEN_BUFFER_INFO = CONSOLE_SCREEN_BUFFER_INFO()
        guard GetConsoleScreenBufferInfo(handle, &info) else { return nil }
        return info.wAttributes
    }()
    
    private func setConsoleColor(_ color: ConsoleColor) {
        guard let handle = Self.consoleHandle else { return }
        SetConsoleTextAttribute(handle, color.rawValue)
    }
    
    private func restoreConsoleColor() {
        guard let handle = Self.consoleHandle,
              let original = Self.originalAttributes else { return }
        SetConsoleTextAttribute(handle, original)
    }
    
    private func log(level: String, message: String, color: ConsoleColor) {
        let timestamp = Log.dateFormatter.string(from: Date())
        let output = "\(level) \(timestamp) [\(subsystem)] [\(category)] \(message)"
        
        setConsoleColor(color)
        print(output)
        restoreConsoleColor()
    }
    
    public func trace(_ message: String) {
        log(level: "TRACE", message: message, color: .darkGray)
    }
    
    public func debug(_ message: String) {
        log(level: "DEBUG", message: message, color: .gray)
    }
    
    public func info(_ message: String) {
        log(level: "INFO ", message: message, color: .cyan)
    }
    
    public func notice(_ message: String) {
        log(level: "NOTICE", message: message, color: .blue)
    }
    
    public func warning(_ message: String) {
        log(level: "WARN ", message: message, color: .red)
    }
    
    public func error(_ message: String) {
        log(level: "ERROR", message: message, color: .red)
    }
    
    public func critical(_ message: String) {
        log(level: "CRITICAL", message: message, color: .magenta)
    }
    
    public func fault(_ message: String) {
        log(level: "FAULT", message: message, color: .magenta)
    }
#else
    
    // Fallback for non-Windows platforms without OSLog
    private func log(level: String, message: String) {
        let timestamp = Log.dateFormatter.string(from: Date())
        let output = "\(level) \(timestamp) [\(subsystem)] [\(category)] \(message)"
        print(output)
    }
    
    public func trace(_ message: String) {
        log(level: "TRACE", message: message)
    }
    
    public func debug(_ message: String) {
        log(level: "DEBUG", message: message)
    }
    
    public func info(_ message: String) {
        log(level: "INFO ", message: message)
    }
    
    public func notice(_ message: String) {
        log(level: "NOTICE", message: message)
    }
    
    public func warning(_ message: String) {
        log(level: "WARN ", message: message)
    }
    
    public func error(_ message: String) {
        log(level: "ERROR", message: message)
    }
    
    public func critical(_ message: String) {
        log(level: "CRITICAL", message: message)
    }
    
    public func fault(_ message: String) {
        log(level: "FAULT", message: message)
    }
#endif // os(Windows)
}
#endif // canImport(OSLog)

/// Main logging interface providing signal handling and log file management.
public enum Log {
    
    @frozen public enum Level {
        public static let Trace    = 0
        public static let Debug    = 1
        public static let Info     = 2
        public static let Notice   = 3
        public static let Warning  = 4
        public static let Error    = 5
        public static let Critical = 6
        public static let Fault    = 7
        public static let Fatal    = 8
    }
    
    /// Controls the minimum log level. Messages with a lower level will be ignored.
    /// Default is Debug in DEBUG builds, Info in RELEASE builds.
    nonisolated(unsafe) public static var logLevel: Int = {
#if DEBUG
        return Level.Debug
#else
        return Level.Info
#endif
    }()

    /// Defult log file names.
    nonisolated(unsafe) public static var defaultLogFileName = "Log"
    
    /// Defaul sybsystem
    nonisolated(unsafe) public static var defaultSubsystem = "Default"
    
    /// Live logging
    nonisolated(unsafe) public static var enableLiveLogging = false
    
    nonisolated(unsafe) private static var _previousLogLevel: Int?
    
    /// Live logging
    nonisolated(unsafe) public static var enableVerboseLogging = false {
        didSet {
            if enableVerboseLogging {
                _previousLogLevel = logLevel
                logLevel = Level.Trace
            } else {
                if let previousLogLevel = _previousLogLevel { logLevel =  previousLogLevel }
            }
        }
    }
    
    /// Specifies where log files should be written.
    public enum LogPath {
        /// Log files will be written to the specified absolute path.
        case absolute(String)
        /// Log files will be written to a path relative to the binary location.
        /// If nil, files will be written directly to the binary directory.
        case relative(String? = nil)
        /// Log files will be written to the application support directory, optionally in a subdirectory.
        case applicationSupport(path: String? = nil)
    }
    
    /// Path for log files. Default is `.applicationSupport()`.
    nonisolated(unsafe) public static var logPath: LogPath = .applicationSupport()
    
    /// Specifies how log files should be created or appended to.
    public enum FileAppendingType {
        /// New log sessions will be appended to existing log files.
        /// If the log file doesn't exist, it will be created.
        case appendToExistingLogFile
        /// A new numbered log file will be created for each session.
        /// Files are named with incrementing numbers (e.g., Log.log, Log-1.log, Log-2.log).
        case alwaysCreateNewLogFile
        /// Appends to the highest numbered log file if it has fewer than `fileLimit` lines.
        /// If the file has `fileLimit` or more lines, creates a new file with the next number.
        /// The resulting file may exceed `fileLimit` after appending.
        case appendCreatingNewFileIfLimitIsReached
    }
    
    /// Controls how log files are created. Default is `.appendToExistingLogFile`.
    nonisolated(unsafe) public static var fileAppendingType: FileAppendingType = .appendToExistingLogFile
    
    nonisolated(unsafe) public static var fileLimit: Int = 2_500
    
    /// Controls whether session header and footer are written when saving log sessions. Default is `true`.
    nonisolated(unsafe) public static var writeSessionHeaderAndFooter: Bool = true
}

extension Log {
    
    /// Cache for file name lookups to avoid repeated path parsing.
    private static let fileNameCacheLock = NSRecursiveLock()
    
    nonisolated(unsafe) private static var fileNameCache: [String: String] = [:]
    
    @inline(__always)
    /// Extracts the file name from a file path.
    /// - Parameter path: The full file path.
    /// - Returns: The file name without extension, or "UNDEFINED" if extraction fails.
    public static func fileName(from path: String) -> String {
        // Check cache first
        fileNameCacheLock.lock()
        defer { fileNameCacheLock.unlock() }
        
        if let cached = fileNameCache[path] {
            return cached
        }
        
        // Compute file name
        let name = URL(fileURLWithPath: path)
            .lastPathComponent
            .split(separator: ".", maxSplits: 1)
            .first ?? "UNDEFINED"
        
        let result = String(name)
        
        // Store in cache
        fileNameCache[path] = result
        
        return result
    }
}

extension Log {
    @inlinable
    @_alwaysEmitIntoClient
    public static func _injected_logFatal(_ message: String, _ file: String = #file, _ function: String = #function) -> Never {
        let fileName = Log.fileName(from: file)
        let function = "\(fileName).\(function)"
        Logger(subsystem: subsystem, category: function).fault("\(message)")
        let message = "FATAL  \(Log.dateFormatter.string(from: Date())) [\(subsystem)] [\(function)] \(message)"
        Log.History.add(message)
        Log.callMessageHook(message)
        Log.callFaultHook(subsystem, message)
        Log.saveCurrentSession()
        fatalError(message)
    }
}

extension Log: Loggable {
    
    /// Finds the next available log file number by counting existing log files.
    /// Returns the number N to use for the postfix `-N`, where N is the count of existing log files.
    /// Returns nil if no log files exist yet (will use base name without number).
    private static func findNextLogFileNumber(in directory: URL, baseFileName: String) -> Int? {
        let fileManager = FileManager.default
        
        guard let files = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else {
            return nil
        }
        
        let basePattern = baseFileName
        var logFileCount = 0
        
        for file in files {
            // Only consider .log files
            guard file.pathExtension == "log" else {
                continue
            }
            
            let fileName = file.deletingPathExtension().lastPathComponent
            
            // Check if it matches the base name exactly (no number) or the pattern {baseFileName}-N
            if fileName == basePattern {
                logFileCount += 1
            } else if fileName.hasPrefix(basePattern + "-") {
                let suffix = String(fileName.dropFirst(basePattern.count + 1))
                // Only count if it's a valid number (matches the pattern)
                if Int(suffix) != nil {
                    logFileCount += 1
                }
            }
        }
        
        // If no files found, return nil (will use base name without number)
        // If files found, return the count (which will be the postfix number)
        return logFileCount > 0 ? logFileCount : nil
    }
    
    /// Finds the highest numbered log file in a directory.
    /// Returns the highest number found, or nil if only the base file exists or no files exist.
    /// - Parameters:
    ///   - directory: The directory to search in.
    ///   - baseFileName: The base name of log files (e.g., "Log").
    /// - Returns: The highest number found (e.g., 5 for Log-5.log), or nil if no numbered files exist.
    private static func findHighestLogFileNumber(in directory: URL, baseFileName: String) -> Int? {
        let fileManager = FileManager.default
        
        guard let files = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else {
            return nil
        }
        
        var highestNumber: Int? = nil
        
        for file in files {
            // Only consider .log files
            guard file.pathExtension == "log" else {
                continue
            }
            
            let fileName = file.deletingPathExtension().lastPathComponent
            
            // Check if it matches the pattern {baseFileName}-N
            if fileName.hasPrefix(baseFileName + "-") {
                let suffix = String(fileName.dropFirst(baseFileName.count + 1))
                if let number = Int(suffix) {
                    if let current = highestNumber {
                        highestNumber = max(current, number)
                    } else {
                        highestNumber = number
                    }
                }
            }
        }
        
        return highestNumber
    }
    
    /// Counts the number of lines in a file.
    /// - Parameter fileURL: The URL of the file to count lines in.
    /// - Returns: The number of lines, or 0 if the file cannot be read.
    private static func countLines(in fileURL: URL) -> Int {
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return 0
        }
        
        // Count newline characters for accurate line count
        var lineCount = 0
        content.enumerateLines { _, _ in
            lineCount += 1
        }
        return lineCount
    }
    
    /// Creates the directory at the specified URL if it doesn't exist.
    /// - Parameter directory: The URL of the directory to create.
    /// - Returns: `true` if the directory exists or was created successfully, `false` otherwise.
    @discardableResult
    private static func createDirectoryIfNeeded(at directory: URL) -> Bool {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directory.path) {
            do {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create directory for log file: '\(error.localizedDescription)'.")
                return false
            }
        }
        return true
    }
    
    /// Unique session identifier for the current logging session.
    public static let sessionID = UUID().uuidString.uppercased()
    
    /// Saves the current log session to a file in the application support directory.
    /// The file name format is: `{logFilePrefix}_{sessionID}_{date}.log`
    /// If `logPath` is set to `.absolute`, the log file will be written to that path instead.
    public static func saveCurrentSession() {
        let log: String
        if writeSessionHeaderAndFooter {
            log = "--- LOG FOR SESSION \(sessionID) AT \(dateFormatter.string(from: Date())) ---"
                + "\n"
                + "\n"
                + History.converged()
                + "\n"
                + "\n"
                + "--- END LOG FOR SESSION \(sessionID) ---"
                + "\n"
        } else {
            log = History.converged()
                + "\n"
        }
        
        let fileManager = FileManager.default
        let directoryURL: URL
        let baseLogName = defaultLogFileName
        
        // Determine the directory where log files should be written
        switch logPath {
        case .absolute(let absolutePath):
            let absoluteURL = URL(fileURLWithPath: absolutePath)
            var isDirectory: ObjCBool = false
            
            // Check if the path exists and is a directory
            if fileManager.fileExists(atPath: absolutePath, isDirectory: &isDirectory) && isDirectory.boolValue {
                directoryURL = absoluteURL
            } else {
                // It's a file path or doesn't exist, use its parent directory
                let parentDirectory = absoluteURL.deletingLastPathComponent()
                guard createDirectoryIfNeeded(at: parentDirectory) else { return }
                directoryURL = parentDirectory
            }
            
        case .relative(let relativePath):
            // Use a path relative to the binary location (from CommandLine.arguments[0])
            let binaryPath = CommandLine.arguments[0]
            let binaryDirectory = URL(fileURLWithPath: binaryPath).deletingLastPathComponent()
            if let relativePath {
                let targetDirectory = binaryDirectory.appendingPathComponent(relativePath)
                guard createDirectoryIfNeeded(at: targetDirectory) else { return }
                directoryURL = targetDirectory
            } else {
                // If nil, use the binary directory directly
                directoryURL = binaryDirectory
            }
            
        case .applicationSupport(let subpath):
            // Use the application support directory, optionally with a subdirectory
            guard let appSupportPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                print("Failed to get path for application support directory.")
                return
            }
            
            if let subpath = subpath {
                let subdirectory = appSupportPath.appendingPathComponent(subpath)
                guard createDirectoryIfNeeded(at: subdirectory) else { return }
                directoryURL = subdirectory
            } else {
                directoryURL = appSupportPath
            }
        }
        
        // Determine the log file name and whether to append
        let logFileName: String
        var shouldAppend = false
        
        switch fileAppendingType {
        case .appendToExistingLogFile:
            // When appending, use the base name
            logFileName = "\(baseLogName).log"
            shouldAppend = true
            
        case .alwaysCreateNewLogFile:
            // When creating new files, find the next number
            if let nextNumber = findNextLogFileNumber(in: directoryURL, baseFileName: baseLogName) {
                logFileName = "\(baseLogName)-\(nextNumber).log"
            } else {
                // No existing files, use base name (will be the first file)
                logFileName = "\(baseLogName).log"
            }
            
        case .appendCreatingNewFileIfLimitIsReached:
            // Find the highest numbered file and check its line count
            let baseFile = directoryURL.appendingPathComponent("\(baseLogName).log")
            let baseFileExists = fileManager.fileExists(atPath: baseFile.path)
            
            if let highestNumber = findHighestLogFileNumber(in: directoryURL, baseFileName: baseLogName) {
                // There are numbered files, check the highest one
                let highestFile = directoryURL.appendingPathComponent("\(baseLogName)-\(highestNumber).log")
                let lineCount = countLines(in: highestFile)
                
                if lineCount < fileLimit {
                    // Append to the highest numbered file
                    logFileName = "\(baseLogName)-\(highestNumber).log"
                    shouldAppend = true
                } else {
                    // Create a new file with the next number
                    logFileName = "\(baseLogName)-\(highestNumber + 1).log"
                }
            } else if baseFileExists {
                // Only base file exists, check its line count
                let lineCount = countLines(in: baseFile)
                
                if lineCount < fileLimit {
                    // Append to the base file
                    logFileName = "\(baseLogName).log"
                    shouldAppend = true
                } else {
                    // Create the first numbered file
                    logFileName = "\(baseLogName)-1.log"
                }
            } else {
                // No files exist, create the base file
                logFileName = "\(baseLogName).log"
            }
        }
        
        let filePath = directoryURL.appendingPathComponent(logFileName)
        
        do {
            let fileExists = fileManager.fileExists(atPath: filePath.path)
            
            if shouldAppend && fileExists {
                // Append to existing file
                if let fileHandle = FileHandle(forWritingAtPath: filePath.path) {
                    defer { fileHandle.closeFile() }
                    fileHandle.seekToEndOfFile()
                    if let data = log.data(using: .utf8) {
                        fileHandle.write(data)
                    }
                } else {
                    print("Failed to open file handle for appending: '\(filePath.path)'.")
                }
            } else {
                // Write to new file
                try log.write(to: filePath, atomically: true, encoding: .utf8)
            }
        } catch {
            print("Failed to save diagnostics file with error '\(error.localizedDescription)'.")
        }
    }
    
    /// Removes log files older than the specified interval from the application support directory.
    /// - Parameter interval: The maximum age in days. Logs older than this will be deleted.
    public static func cleanOldLogs(interval: Double) {
        let fileManager = FileManager.default
        guard let appSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            print("Failed to get ref to app support directory.")
            return
        }
        do {
            // Get all files
            let filesURLs = try fileManager.contentsOfDirectory(at: appSupportDirectory, includingPropertiesForKeys: nil)
            print("Found \(filesURLs.count) files in app support directory.")
            // Get logs
            let logsURLs = filesURLs.filter {
                $0.deletingPathExtension().lastPathComponent.contains(defaultLogFileName)
            }
            print("Found \(logsURLs.count) logs.")
            
            if logsURLs.count > 0 {
                // Filter by creation date
                let oldLogsURLs = try logsURLs.filter {
                    let attributes = try fileManager.attributesOfItem(atPath: $0.path)
                    let timeFromLogCreation = Swift.abs((attributes[.creationDate] as? NSDate)?.timeIntervalSinceNow ?? 0)
                    let timeLimit = interval * 24 * 60 * 60
                    print("Log file '\($0.absoluteURL.deletingPathExtension().lastPathComponent)' created since \(timeFromLogCreation)s, limit is '\(timeLimit)'s.")
                    return timeFromLogCreation > timeLimit
                }
                print("Filtered \(oldLogsURLs.count) old logs.")
                
                if oldLogsURLs.count > 0 {
                    // Deleted log files
                    for url in oldLogsURLs {
                        try fileManager.removeItem(at: url)
                    }
                    print("Removed old logs.")
                }
            }
        } catch {
            print("Failed to get files in app support director, error '\(error.localizedDescription)'.")
        }
    }
}
