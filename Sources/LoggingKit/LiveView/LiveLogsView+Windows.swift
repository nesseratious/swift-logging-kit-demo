//
//  LiveLogsView+Windows.swift
//  LoggingKit
//
//  Created by Denis Esie on 08.12.2023.
//

import Foundation

#if os(Windows)
import WinSDK

/// Windows-specific view for displaying and searching through debug logs.
public struct LiveLogsView {
    /// Initializes a new debug logs view.
    public init() {}
}

// Helper extension to convert String to wide string (LPWSTR)
private extension String {
    var wide: [WCHAR] {
        return self.utf16.map { WCHAR($0) } + [0]
    }
}

#endif // os(Windows)
