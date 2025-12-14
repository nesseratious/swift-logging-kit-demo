//
//  Loggable+Extension.swift
//  LoggingKit
//
//  Created by Denis Esie on 27.11.2025.
//

import Foundation

extension Loggable {
    var runningPreview: Bool {
#if canImport(SwiftUI)
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
#else
        return false
#endif
    }
}

extension Log {
    @inline(__always)
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
}
