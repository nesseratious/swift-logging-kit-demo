//
//  DebugLogsViewModel.swift
//  LoggingKit
//
//  Created by Denis Esie on 23.11.2025.
//

import Foundation

#if canImport(SwiftUI)
import Combine
import SwiftUI

/// View model for managing debug log display and filtering.
public final class LiveLogsViewModel: ObservableObject {

    /// Token for search functionality.
    @frozen public struct LogToken: Identifiable, Hashable {
        public let id = UUID()
        public var label: String
        public var systemImage: String
        
        public init(label: String, systemImage: String) {
            self.label = label
            self.systemImage = systemImage
        }
    }
    /// The shared log history instance.
    @Published public var logHistory = LiveLogHistory.shared
    
    /// Filtered and sorted log messages for display.
    @Published public var localLogs = [Log.DebugMessage]()
    
    /// Search text for filtering logs by message or subsystem.
    @Published public var search = ""
    
    /// Subsystems to filter by. Empty array means no subsystem filtering.
    @Published public var subsystems = [String]()
    
    /// Log levels to filter by. Empty array means no level filtering.
    @Published public var levels = [Log.DebugMessage.Level]()
    
    /// Whether debug logging is enabled for testing.
    @Published public var isDebugLoggingEnabled = false
    
    /// Search scope for filtering by log level.
    @Published public var searchScope = Log.DebugMessage.Level.info
    
    private let possibleTokens: [LogToken] = [
        LogToken(label: "Type", systemImage: "list.bullet.circle.fill"),
        LogToken(label: "Subsystem", systemImage: "gearshape.2")
    ]
    /// Search tokens for advanced filtering.
    @Published public var tokens: [LogToken] = []
    
    private var cancelables: Set<AnyCancellable> = []
    
    /// Initializes the view model and sets up log history observation.
    public init() {
        logHistory.$logs
            .sink { [weak self] logs in
                self?.update(logs: logs)
            }.store(in: &cancelables)
        
        $search.sink { [weak self] searchText in
            guard let self else { return }
            
            // Check for Type:text or type:text pattern
            let pattern = #"(?i)type:\s*(\S+)"#
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: searchText, range: NSRange(searchText.startIndex..., in: searchText)),
               match.numberOfRanges > 1 {
                
                let textRange = Range(match.range(at: 1), in: searchText)!
                let extractedText = String(searchText[textRange])
                
                // Create token if it doesn't already exist
                let typeToken = LogToken(label: "Type: \(extractedText)", systemImage: "list.bullet.circle.fill")
                if !self.tokens.contains(where: { $0.label == typeToken.label }) {
                    self.tokens.append(typeToken)
                }
                
                // Remove the matched pattern from search string
                let fullMatchRange = Range(match.range, in: searchText)!
                var updatedSearch = searchText
                updatedSearch.removeSubrange(fullMatchRange)
                // Trim any leading/trailing whitespace
                updatedSearch = updatedSearch.trimmingCharacters(in: .whitespaces)
                
                // Update search string (avoid infinite loop by checking if different)
                if updatedSearch != self.search {
                    self.search = updatedSearch
                }
            }
            
            self.update(logs: self.logHistory.logs)
        }.store(in: &cancelables)
    }
    
    /// Updates the filtered logs based on current search text, subsystems, and levels.
    /// - Parameter logs: The full array of log messages to filter.
    public func update(logs: [Log.DebugMessage]) {
        var filtered = logs
        
        // Filter by search text
        if !search.isEmpty {
            let searchUpper = search.uppercased()
            filtered = filtered.filter { 
                $0.message.uppercased().contains(searchUpper) ||
                $0.subsystem.uppercased().contains(searchUpper)
            }
        }
        
        // Filter by subsystems
        if !subsystems.isEmpty {
            filtered = filtered.filter { subsystems.contains($0.subsystem) }
        }
        
        // Filter by levels
        if !levels.isEmpty {
            filtered = filtered.filter { levels.contains($0.level) }
        }
        
        // Sort by timestamp (oldest first)
        localLogs = filtered.sorted { $0.timestamp < $1.timestamp }
    }
}
#endif // canImport(SwiftUI)
