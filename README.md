# LoggingKit

A Swift logging framework with support for iOS, watchOS, and macOS.

## Features

- Structured logging with multiple severity levels (trace, debug, info, notice, warning, error, critical, fault)
- Performance and user event tracking
- Swift macros for compile-time logging
- Log history with SwiftUI views for debugging
- Integration with Apple's OSLog
- Session-based log file management
- Custom hooks for log interception
- Platform-specific support (iOS, watchOS, macOS)

## Installation

Add this package to your `Package.swift`:

```swift
dependencies: [
    .package(path: "../Libraries/LoggingKit")
]
```

Or add it as a local package in Xcode by dragging the LoggingKit folder into your project.

## API Reference

### Core Types

**`Log`** - Main logging interface
- `Log.Level` - Log severity levels (Trace, Debug, Info, Notice, Warning, Error, Critical, Fault)
- `Log.logLevel: Int` - Minimum log level (default: Debug in DEBUG, Info in RELEASE)
- `Log.defaultSubsystem: String` - Default subsystem identifier
- `Log.defaultLogFileName: String` - Default log file name
- `Log.enableLiveLogging: Bool` - Enable live log collection for SwiftUI views
- `Log.enableVerboseLogging: Bool` - Enable verbose logging (includes category in history)
- `Log.logPath: Log.LogPath` - Path configuration for log files
- `Log.fileAppendingType: Log.FileAppendingType` - How log files are created/appended
- `Log.fileLimit: Int` - Maximum lines per log file
- `Log.sessionID: String` - Unique session identifier
- `Log.dateFormatter: DateFormatter` - Date formatter for timestamps

**`Loggable`** - Protocol for types that can log
- `static var subsystem: String` - Subsystem identifier
- `static var file: String` - Log file name

**`LogFunctionsProtocol`** - Protocol providing logging methods

### Logging Methods

**Static methods** (available on `Loggable` types):
- `logTrace(_:file:function:)` - Trace-level logging
- `logDebug(_:file:function:)` - Debug-level logging
- `logInfo(_:file:function:)` - Info-level logging
- `logUserEvent(_:file:function:)` - User event logging
- `logPerformance(_:file:function:)` - Performance logging
- `logSuccess(_:file:function:)` - Success logging
- `logNotice(_:file:function:)` - Notice-level logging
- `logWarning(_:file:function:)` - Warning-level logging
- `logError(_:file:function:)` - Error-level logging
- `logCritical(_:file:function:)` - Critical-level logging
- `logFault(_:file:function:)` - Fault-level logging

**Instance methods** (same names, available on `Loggable` instances)

**Macros** (compile-time logging with privacy support):
- `#logTrace(_:logger:)` - Trace-level macro
- `#logDebug(_:logger:)` - Debug-level macro
- `#logInfo(_:logger:)` - Info-level macro
- `#logUserEvent(_:logger:)` - User event macro
- `#logPerformance(_:logger:)` - Performance macro
- `#logSuccess(_:logger:)` - Success macro
- `#logNotice(_:logger:)` - Notice-level macro
- `#logWarning(_:logger:)` - Warning-level macro
- `#logError(_:logger:)` - Error-level macro
- `#logCritical(_:logger:)` - Critical-level macro
- `#logFault(_:logger:)` - Fault-level macro

### History & File Management

**`Log.History`**:
- `add(_:)` - Add log entry to history
- `converged() -> String` - Get all history as string

**File operations**:
- `Log.saveCurrentSession()` - Save current session to file
- `Log.cleanOldLogs(interval:)` - Remove logs older than specified days
- `Log.fileName(from:) -> String` - Extract filename from path

### Hooks

Register hooks to intercept log messages:
- `Log.registerMessageHook(_:)` - Hook for all messages
- `Log.registerTraceHook(_:)` - Hook for trace messages
- `Log.registerDebugHook(_:)` - Hook for debug messages
- `Log.registerInfoHook(_:)` - Hook for info messages
- `Log.registerUserEventHook(_:)` - Hook for user events
- `Log.registerPerformanceHook(_:)` - Hook for performance logs
- `Log.registerSuccessHook(_:)` - Hook for success logs
- `Log.registerNoticeHook(_:)` - Hook for notice messages
- `Log.registerWarningHook(_:)` - Hook for warning messages
- `Log.registerErrorHook(_:)` - Hook for error messages
- `Log.registerCriticalHook(_:)` - Hook for critical messages
- `Log.registerFaultHook(_:)` - Hook for fault messages

### SwiftUI Components

**`LiveLogsView`** - SwiftUI view for displaying live logs

**`LiveLogsViewModel`** - View model for log filtering and display
- `logHistory: LiveLogHistory` - Shared log history
- `localLogs: [Log.DebugMessage]` - Filtered logs
- `search: String` - Search text
- `subsystems: [String]` - Subsystem filter
- `levels: [Log.DebugMessage.Level]` - Level filter

**`Log.DebugMessage`** - Debug log message model
- `subsystem: String` - Subsystem identifier
- `message: String` - Log message
- `level: Level` - Severity level
- `timestamp: Date` - Creation timestamp
- Static factory methods: `trace()`, `debug()`, `info()`, `userEvent()`, `performance()`, `success()`, `notice()`, `warning()`, `error()`, `critical()`, `fault()`

**`LiveLogHistory`** - Observable log history
- `shared: LiveLogHistory` - Singleton instance
- `logs: [Log.DebugMessage]` - Published log array
- `add(_:)` - Add log message

## Usage

### Basic Logging

Make any type conform to `Loggable`:

```swift
extension MyClass: Loggable {
    static let subsystem = "MySubsystem"
}
```

Use logging methods:

```swift
MyClass.logInfo("This is an info message")
MyClass.logWarning("This is a warning")
MyClass.logError("This is an error")
```

Or use macros:

```swift
#logInfo("This is an info message")
#logWarning("This is a warning")
#logError("This is an error")
```

### Configuration

```swift
// Set log level
Log.logLevel = Log.Level.Info

// Enable live logging for SwiftUI views
Log.enableLiveLogging = true

// Enable verbose logging (includes category)
Log.enableVerboseLogging = true

// Configure log file path
Log.logPath = .applicationSupport(path: "Logs")

// Configure file appending behavior
Log.fileAppendingType = .appendCreatingNewFileIfLimitIsReached
Log.fileLimit = 5000
```

### Viewing Logs

```swift
import LoggingKit
import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            LiveLogsView()
        }
    }
}
```

### Saving Log Sessions

```swift
// Save current session
Log.saveCurrentSession()

// Clean old logs
Log.cleanOldLogs(interval: 7.0) // Remove logs older than 7 days
```

### Hooks

```swift
// Register a hook for all messages
Log.registerMessageHook { message in
    print("Log: \(message)")
}

// Register a hook for errors
Log.registerErrorHook { subsystem, message in
    // Send to crash reporting service
    CrashReporter.report(subsystem: subsystem, error: message)
}
```

## Requirements

- iOS 16.0+
- watchOS 10.0+
- macOS 13.0+
- Swift 5.9+
