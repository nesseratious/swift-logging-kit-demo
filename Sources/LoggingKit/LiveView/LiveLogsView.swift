//
//  LiveLogsView.swift
//  LoggingKit
//
//  Created by Denis Esie on 08.12.2023.
//

import Foundation
import SwiftUI
import Combine

/// SwiftUI view for displaying and searching through debug logs.
public struct LiveLogsView: View {
    @ObservedObject var model = LiveLogsViewModel()
    
    /// Initializes a new debug logs view.
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List(model.localLogs) { log in
                VStack(alignment: .leading, spacing: 6.0) {
                    Text(verbatim: log.message)
#if os(macOS)
                        .font(.system(size: 14.0))
#else
                        .font(.system(size: 18.0))
#endif
                    HStack(alignment: .center, spacing: 8.0) {
                        log.image
                            .renderingMode(.template)
                            .resizable(resizingMode: .tile)
                            .frame(width: log.imageSize.width, height: log.imageSize.height)
                            .padding(4)
                            .foregroundStyle(.white)
                            .background(log.imageColor)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                        
                    Text(log.timestamp.formatted(date: .omitted, time: .standard))
                        .font(.system(size: 14.0, weight: .bold))
                        .opacity(0.5)
                        
                    Image(systemName: "gearshape.2")
                            .font(.system(size: 14.0, weight: .medium))
                            .opacity(0.5)
                        
                    Text(verbatim: log.subsystem)
                        .font(.system(size: 14.0, weight: .bold))
                        .opacity(0.5)
                    }
                }
#if os(macOS)
                .frame(height: 50.0)
                .listRowBackground(log.tintColor.opacity(0.5))
#else
                .frame(height: 40.0)
                .listRowBackground(log.tintColor.opacity(0.75))
#endif
            }
            .searchable(
                text: $model.search,
                tokens: $model.tokens,
                placement: .toolbar,
                prompt: "Filter",
                token: { token in
                    Label(token.label, systemImage: token.systemImage)
                }
            )
            .searchScopes($model.searchScope) {
                Text("All").tag(Log.DebugMessage.Level.trace)
                Text("Info").tag(1)
                Text("Warnings").tag(2)
                Text("Errors").tag(3)
            }
            //#if !os(macOS)
            //            .searchToolbarBehavior(.minimize)
            //#endif
            .toolbar {
                ToolbarItemGroup(placement: .navigation) {
                    Menu("File", systemImage: "document.on.document") {
                        Button("EWS.log", systemImage: "text.document") {
                            
                        }
                        Button("common.log", systemImage: "text.document") {
                            
                        }
                        Button("calapi.log", systemImage: "text.document") {
                            
                        }
                    }
                }
                ToolbarItemGroup(placement: .principal) {
                    Text("common.log")
                }
                ToolbarItemGroup(placement: .secondaryAction) {
                    Button(action: {
                        model.isDebugLoggingEnabled.toggle()
                    }) {
                        Text(model.isDebugLoggingEnabled ? "Stop Test Logging" : "Start Test Logging")
                            .padding(.horizontal, 4.0)
                            .foregroundStyle(model.isDebugLoggingEnabled ? Color.red : Color.green)
                    }
                }
            }
        }
        .task(id: model.isDebugLoggingEnabled) {
            guard model.isDebugLoggingEnabled else { return }
            
            Log.enableLiveLogging = true
            Log.logLevel = Log.Level.Trace
            
            enum LogType: CaseIterable {
                case trace, debug, info, userEvent, performance, success, notice, warning, error, critical, fault
            }
            
            let weightedLogTypes: [LogType] = [
                .trace, .trace, .trace, .trace, .trace,
                .debug, .debug, .debug, .debug,
                .info, .info, .info,
                .userEvent, .performance, .success, .notice, .warning, .error, .critical, .fault
            ]
            
            while !Task.isCancelled && model.isDebugLoggingEnabled {
                let randomType = weightedLogTypes.randomElement()!
                let randomNumber = Int.random(in: 1...1000)
                
                switch randomType {
                case .trace:
                    PreviewLogger.logTrace("Trace message \(randomNumber)")
                case .debug:
                    PreviewLogger.logDebug("Debug message \(randomNumber)")
                case .info:
                    PreviewLogger.logInfo("Info message \(randomNumber)")
                case .userEvent:
                    PreviewLogger.logUserEvent("User event message \(randomNumber)")
                case .performance:
                    PreviewLogger.logPerformance("Performance message \(randomNumber)")
                case .success:
                    PreviewLogger.logSuccess("Success message \(randomNumber)")
                case .notice:
                    PreviewLogger.logNotice("Notice message \(randomNumber)")
                case .warning:
                    PreviewLogger.logWarning("Warning message \(randomNumber)")
                case .error:
                    PreviewLogger.logError("Error message \(randomNumber)")
                case .critical:
                    PreviewLogger.logCritical("Critical message \(randomNumber)")
                case .fault:
                    PreviewLogger.logFault("Fault message \(randomNumber)")
                }
                
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            }
            
            Log.enableLiveLogging = false
        }
    }
}

private enum PreviewLogger: LogFunctionsProtocol {
    static let subsystem = "PreviewLogger"
}

#Preview {
    LiveLogsView()
}
