//
//  LoggingMacros.swift
//  LoggingKit
//
//  Created by Denis Esie on 27.11.2025.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// MARK: - Individual macro implementations

public struct LogTraceMacro: ExpressionMacro {
    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        guard let firstArgument = node.arguments.first else {
            throw MacroError.missingArgument
        }
        let message = firstArgument.expression
        let redactedMessage = redactPrivateInterpolations(in: message)
        let logger = node.arguments.dropFirst().first?.expression
        
        // Determine if we're inside a method or a global function, and get properties
        let (_, typeExpr) = context.enclosingFunctionAndType()
        
        // Check if enclosing type declares conformance to Loggable
        let defaultSubsystemExpr: String
        if declaresConformance(to: "Loggable", in: typeExpr) {
            defaultSubsystemExpr = "Self.subsystem"
        } else {
            defaultSubsystemExpr = "Log.defaultSubsystem"
        }
        
        let loggerExpr: String
        let subsystemExpr: String
        if let logger {
            let loggerStr = "\(logger)".replacingOccurrences(of: ".self", with: "")
            loggerExpr = "Logger(subsystem: \(loggerStr).subsystem, category: category)"
            subsystemExpr = "\(loggerStr).subsystem"
        } else {
            loggerExpr = "Logger(subsystem: \(defaultSubsystemExpr), category: category)"
            subsystemExpr = defaultSubsystemExpr
        }
        
        return
            """
            {
                guard Log.Level.Trace >= Log.logLevel else { return }
                let fileName = Log.fileName(from: "\\(#file)")
                let category = "\\(fileName).\\(#function)"
                let message = \(redactedMessage)
                \(raw: loggerExpr).trace(\(message))
                Log.History.add("TRACE  \\(Log.dateFormatter.string(from: Date())) [\\(\(raw: subsystemExpr))] \\(Log.enableVerboseLogging ? "[\\(category)]" : "") \\(message)")
                if Log.enableLiveLogging { LiveLogHistory.shared.add(.trace(subsystem: \(raw: subsystemExpr), message: message)) }
                Log.callMessageHook(message)
                Log.callTraceHook(\(raw: subsystemExpr), message)
            }()
            """
    }
}

public struct LogDebugMacro: ExpressionMacro {
    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        guard let firstArgument = node.arguments.first else {
            throw MacroError.missingArgument
        }
        let message = firstArgument.expression
        let redactedMessage = redactPrivateInterpolations(in: message)
        let logger = node.arguments.dropFirst().first?.expression
        
        // Determine if we're inside a method or a global function
        let (_, type) = context.enclosingFunctionAndType()
        let defaultSubsystemExpr = declaresConformance(to: "Loggable", in: type) ? "Self.subsystem" : "Log.defaultSubsystem"
        
        let loggerExpr: String
        let subsystemExpr: String
        if let logger {
            let loggerStr = "\(logger)".replacingOccurrences(of: ".self", with: "")
            loggerExpr = "Logger(subsystem: \(loggerStr).subsystem, category: category)"
            subsystemExpr = "\(loggerStr).subsystem"
        } else {
            loggerExpr = "Logger(subsystem: \(defaultSubsystemExpr), category: category)"
            subsystemExpr = defaultSubsystemExpr
        }
        
        return
            """
            {
                guard Log.Level.Debug >= Log.logLevel else { return }
                let fileName = Log.fileName(from: "\\(#file)")
                let category = "\\(fileName).\\(#function)"
                let message = \(redactedMessage)
                \(raw: loggerExpr).debug(\(message))
                Log.History.add("DEBUG  \\(Log.dateFormatter.string(from: Date())) [\\(\(raw: subsystemExpr))] \\(Log.enableVerboseLogging ? "[\\(category)]" : "") \\(message)")
                if Log.enableLiveLogging { LiveLogHistory.shared.add(.debug(subsystem: \(raw: subsystemExpr), message: message)) }
                Log.callMessageHook(message)
                Log.callDebugHook(\(raw: subsystemExpr), message)
            }()
            """
    }
}

public struct LogInfoMacro: ExpressionMacro {
    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        guard let firstArgument = node.arguments.first else {
            throw MacroError.missingArgument
        }
        let message = firstArgument.expression
        let redactedMessage = redactPrivateInterpolations(in: message)
        let logger = node.arguments.dropFirst().first?.expression
        
        // Determine if we're inside a method or a global function
        let (_, type) = context.enclosingFunctionAndType()
        let defaultSubsystemExpr = declaresConformance(to: "Loggable", in: type) ? "Self.subsystem" : "Log.defaultSubsystem"
        
        let loggerExpr: String
        let subsystemExpr: String
        if let logger {
            let loggerStr = "\(logger)".replacingOccurrences(of: ".self", with: "")
            loggerExpr = "Logger(subsystem: \(loggerStr).subsystem, category: category)"
            subsystemExpr = "\(loggerStr).subsystem"
        } else {
            loggerExpr = "Logger(subsystem: \(defaultSubsystemExpr), category: category)"
            subsystemExpr = defaultSubsystemExpr
        }
        
        return
            """
            {
                guard Log.Level.Info >= Log.logLevel else { return }
                let fileName = Log.fileName(from: "\\(#file)")
                let category = "\\(fileName).\\(#function)"
                let message = \(redactedMessage)
                \(raw: loggerExpr).info(\(message))
                Log.History.add("INFO   \\(Log.dateFormatter.string(from: Date())) [\\(\(raw: subsystemExpr))] \\(Log.enableVerboseLogging ? "[\\(category)]" : "") \\(message)")
                if Log.enableLiveLogging { LiveLogHistory.shared.add(.info(subsystem: \(raw: subsystemExpr), message: message)) }
                Log.callMessageHook(message)
                Log.callInfoHook(\(raw: subsystemExpr), message)
            }()
            """
    }
}

public struct LogUserEventMacro: ExpressionMacro {
    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        guard let firstArgument = node.arguments.first else {
            throw MacroError.missingArgument
        }
        let message = firstArgument.expression
        let redactedMessage = redactPrivateInterpolations(in: message)
        let logger = node.arguments.dropFirst().first?.expression
        
        // Determine if we're inside a method or a global function
        let (_, type) = context.enclosingFunctionAndType()
        let defaultSubsystemExpr = declaresConformance(to: "Loggable", in: type) ? "Self.subsystem" : "Log.defaultSubsystem"
        
        let loggerExpr: String
        let subsystemExpr: String
        if let logger {
            let loggerStr = "\(logger)".replacingOccurrences(of: ".self", with: "")
            loggerExpr = "Logger(subsystem: \(loggerStr).subsystem, category: category)"
            subsystemExpr = "\(loggerStr).subsystem"
        } else {
            loggerExpr = "Logger(subsystem: \(defaultSubsystemExpr), category: category)"
            subsystemExpr = defaultSubsystemExpr
        }
        
        return
            """
            {
                guard Log.Level.Info >= Log.logLevel else { return }
                let fileName = Log.fileName(from: "\\(#file)")
                let category = "\\(fileName).\\(#function)"
                let message = \(redactedMessage)
                \(raw: loggerExpr).info(\(message))
                Log.History.add("EVENT  \\(Log.dateFormatter.string(from: Date())) [\\(\(raw: subsystemExpr))] \\(Log.enableVerboseLogging ? "[\\(category)]" : "") \\(message)")
                if Log.enableLiveLogging { LiveLogHistory.shared.add(.userEvent(subsystem: \(raw: subsystemExpr), message: message)) }
                Log.callMessageHook(message)
                Log.callUserEventHook(\(raw: subsystemExpr), message)
            }()
            """
    }
}

public struct LogPerformanceMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let firstArgument = node.arguments.first else {
            throw MacroError.missingArgument
        }
        let message = firstArgument.expression
        let redactedMessage = redactPrivateInterpolations(in: message)
        let logger = node.arguments.dropFirst().first?.expression
        
        // Determine if we're inside a method or a global function
        let (_, type) = context.enclosingFunctionAndType()
        let defaultSubsystemExpr = declaresConformance(to: "Loggable", in: type) ? "Self.subsystem" : "Log.defaultSubsystem"
        
        let loggerExpr: String
        let subsystemExpr: String
        if let logger {
            let loggerStr = "\(logger)".replacingOccurrences(of: ".self", with: "")
            loggerExpr = "Logger(subsystem: \(loggerStr).subsystem, category: category)"
            subsystemExpr = "\(loggerStr).subsystem"
        } else {
            loggerExpr = "Logger(subsystem: \(defaultSubsystemExpr), category: category)"
            subsystemExpr = defaultSubsystemExpr
        }
        
        return
            """
            {
                guard Log.Level.Info >= Log.logLevel else { return }
                let fileName = Log.fileName(from: "\\(#file)")
                let category = "\\(fileName).\\(#function)"
                let message = \(redactedMessage)
                \(raw: loggerExpr).info(\(message))
                Log.History.add("PERFR  \\(Log.dateFormatter.string(from: Date())) [\\(\(raw: subsystemExpr))] \\(Log.enableVerboseLogging ? "[\\(category)]" : "") \\(message)")
                if Log.enableLiveLogging { LiveLogHistory.shared.add(.performance(subsystem: \(raw: subsystemExpr), message: message)) }
                Log.callMessageHook(message)
                Log.callPerformanceHook(\(raw: subsystemExpr), message)
            }()
            """
    }
}

public struct LogSuccessMacro: ExpressionMacro {
    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        guard let firstArgument = node.arguments.first else {
            throw MacroError.missingArgument
        }
        let message = firstArgument.expression
        let redactedMessage = redactPrivateInterpolations(in: message)
        let logger = node.arguments.dropFirst().first?.expression
        
        // Determine if we're inside a method or a global function
        let (_, type) = context.enclosingFunctionAndType()
        let defaultSubsystemExpr = declaresConformance(to: "Loggable", in: type) ? "Self.subsystem" : "Log.defaultSubsystem"
        
        let loggerExpr: String
        let subsystemExpr: String
        if let logger {
            let loggerStr = "\(logger)".replacingOccurrences(of: ".self", with: "")
            loggerExpr = "Logger(subsystem: \(loggerStr).subsystem, category: category)"
            subsystemExpr = "\(loggerStr).subsystem"
        } else {
            loggerExpr = "Logger(subsystem: \(defaultSubsystemExpr), category: category)"
            subsystemExpr = defaultSubsystemExpr
        }
        
        return
            """
            {
                guard Log.Level.Info >= Log.logLevel else { return }
                let fileName = Log.fileName(from: "\\(#file)")
                let category = "\\(fileName).\\(#function)"
                let message = \(redactedMessage)
                \(raw: loggerExpr).info(\(message))
                Log.History.add("SCCSS  \\(Log.dateFormatter.string(from: Date())) [\\(\(raw: subsystemExpr))] \\(Log.enableVerboseLogging ? "[\\(category)]" : "") \\(message)")
                if Log.enableLiveLogging { LiveLogHistory.shared.add(.success(subsystem: \(raw: subsystemExpr), message: message)) }
                Log.callMessageHook(message)
                Log.callSuccessHook(\(raw: subsystemExpr), message)
            }()
            """
    }
}

public struct LogNoticeMacro: ExpressionMacro {
    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        guard let firstArgument = node.arguments.first else {
            throw MacroError.missingArgument
        }
        let message = firstArgument.expression
        let redactedMessage = redactPrivateInterpolations(in: message)
        let logger = node.arguments.dropFirst().first?.expression
        
        // Determine if we're inside a method or a global function
        let (_, type) = context.enclosingFunctionAndType()
        let defaultSubsystemExpr = declaresConformance(to: "Loggable", in: type) ? "Self.subsystem" : "Log.defaultSubsystem"
        
        let loggerExpr: String
        let subsystemExpr: String
        if let logger {
            let loggerStr = "\(logger)".replacingOccurrences(of: ".self", with: "")
            loggerExpr = "Logger(subsystem: \(loggerStr).subsystem, category: category)"
            subsystemExpr = "\(loggerStr).subsystem"
        } else {
            loggerExpr = "Logger(subsystem: \(defaultSubsystemExpr), category: category)"
            subsystemExpr = defaultSubsystemExpr
        }
        
        return
            """
            {
                guard Log.Level.Notice >= Log.logLevel else { return }
                let fileName = Log.fileName(from: "\\(#file)")
                let category = "\\(fileName).\\(#function)"
                let message = \(redactedMessage)
                \(raw: loggerExpr).notice(\(message))
                Log.History.add("NOTICE \\(Log.dateFormatter.string(from: Date())) [\\(\(raw: subsystemExpr))] \\(Log.enableVerboseLogging ? "[\\(category)]" : "") \\(message)")
                if Log.enableLiveLogging { LiveLogHistory.shared.add(.notice(subsystem: \(raw: subsystemExpr), message: message)) }
                Log.callMessageHook(message)
                Log.callNoticeHook(\(raw: subsystemExpr), message)
            }()
            """
    }
}

public struct LogWarningMacro: ExpressionMacro {
    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        guard let firstArgument = node.arguments.first else {
            throw MacroError.missingArgument
        }
        let message = firstArgument.expression
        let redactedMessage = redactPrivateInterpolations(in: message)
        let logger = node.arguments.dropFirst().first?.expression
        
        // Determine if we're inside a method or a global function
        let (_, type) = context.enclosingFunctionAndType()
        let defaultSubsystemExpr = declaresConformance(to: "Loggable", in: type) ? "Self.subsystem" : "Log.defaultSubsystem"
        
        let loggerExpr: String
        let subsystemExpr: String
        if let logger {
            let loggerStr = "\(logger)".replacingOccurrences(of: ".self", with: "")
            loggerExpr = "Logger(subsystem: \(loggerStr).subsystem, category: category)"
            subsystemExpr = "\(loggerStr).subsystem"
        } else {
            loggerExpr = "Logger(subsystem: \(defaultSubsystemExpr), category: category)"
            subsystemExpr = defaultSubsystemExpr
        }
        
        return
            """
            {
                guard Log.Level.Warning >= Log.logLevel else { return }
                let fileName = Log.fileName(from: "\\(#file)")
                let category = "\\(fileName).\\(#function)"
                let message = \(redactedMessage)
                \(raw: loggerExpr).warning(\(message))
                Log.History.add("WARNG  \\(Log.dateFormatter.string(from: Date())) [\\(\(raw: subsystemExpr))] \\(Log.enableVerboseLogging ? "[\\(category)]" : "") \\(message)")
                if Log.enableLiveLogging { LiveLogHistory.shared.add(.warning(subsystem: \(raw: subsystemExpr), message: message)) }
                Log.callMessageHook(message)
                Log.callWarningHook(\(raw: subsystemExpr), message)
            }()
            """
    }
}

public struct LogErrorMacro: ExpressionMacro {
    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        guard let firstArgument = node.arguments.first else {
            throw MacroError.missingArgument
        }
        let message = firstArgument.expression
        let redactedMessage = redactPrivateInterpolations(in: message)
        let logger = node.arguments.dropFirst().first?.expression
        
        // Determine if we're inside a method or a global function
        let (_, type) = context.enclosingFunctionAndType()
        let defaultSubsystemExpr = declaresConformance(to: "Loggable", in: type) ? "Self.subsystem" : "Log.defaultSubsystem"
        
        let loggerExpr: String
        let subsystemExpr: String
        if let logger {
            let loggerStr = "\(logger)".replacingOccurrences(of: ".self", with: "")
            loggerExpr = "Logger(subsystem: \(loggerStr).subsystem, category: category)"
            subsystemExpr = "\(loggerStr).subsystem"
        } else {
            loggerExpr = "Logger(subsystem: \(defaultSubsystemExpr), category: category)"
            subsystemExpr = defaultSubsystemExpr
        }
        
        return
            """
            {
                guard Log.Level.Error >= Log.logLevel else { return }
                let fileName = Log.fileName(from: "\\(#file)")
                let category = "\\(fileName).\\(#function)"
                let message = \(redactedMessage)
                \(raw: loggerExpr).error(\(message))
                Log.History.add("ERROR  \\(Log.dateFormatter.string(from: Date())) [\\(\(raw: subsystemExpr))] \\(Log.enableVerboseLogging ? "[\\(category)]" : "") \\(message)")
                if Log.enableLiveLogging { LiveLogHistory.shared.add(.error(subsystem: \(raw: subsystemExpr), message: message)) }
                Log.callMessageHook(message)
                Log.callErrorHook(\(raw: subsystemExpr), message)
            }()
            """
    }
}

public struct LogCriticalMacro: ExpressionMacro {
    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        guard let firstArgument = node.arguments.first else {
            throw MacroError.missingArgument
        }
        let message = firstArgument.expression
        let redactedMessage = redactPrivateInterpolations(in: message)
        let logger = node.arguments.dropFirst().first?.expression
        
        // Determine if we're inside a method or a global function
        let (_, type) = context.enclosingFunctionAndType()
        let defaultSubsystemExpr = declaresConformance(to: "Loggable", in: type) ? "Self.subsystem" : "Log.defaultSubsystem"
        
        let loggerExpr: String
        let subsystemExpr: String
        if let logger {
            let loggerStr = "\(logger)".replacingOccurrences(of: ".self", with: "")
            loggerExpr = "Logger(subsystem: \(loggerStr).subsystem, category: category)"
            subsystemExpr = "\(loggerStr).subsystem"
        } else {
            loggerExpr = "Logger(subsystem: \(defaultSubsystemExpr), category: category)"
            subsystemExpr = defaultSubsystemExpr
        }
        
        return
            """
            {
                guard Log.Level.Critical >= Log.logLevel else { return }
                let fileName = Log.fileName(from: "\\(#file)")
                let category = "\\(fileName).\\(#function)"
                let message = \(redactedMessage)
                \(raw: loggerExpr).critical(\(message))
                Log.History.add("CRITCL \\(Log.dateFormatter.string(from: Date())) [\\(\(raw: subsystemExpr))] \\(Log.enableVerboseLogging ? "[\\(category)]" : "") \\(message)")
                if Log.enableLiveLogging { LiveLogHistory.shared.add(.critical(subsystem: \(raw: subsystemExpr), message: message)) }
                Log.callMessageHook(message)
                Log.callCriticalHook(\(raw: subsystemExpr), message)
            }()
            """
    }
}

public struct LogFaultMacro: ExpressionMacro {
    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        guard let firstArgument = node.arguments.first else {
            throw MacroError.missingArgument
        }
        let message = firstArgument.expression
        let redactedMessage = redactPrivateInterpolations(in: message)
        let logger = node.arguments.dropFirst().first?.expression
        
        // Determine if we're inside a method or a global function
        let (_, type) = context.enclosingFunctionAndType()
        let defaultSubsystemExpr = declaresConformance(to: "Loggable", in: type) ? "Self.subsystem" : "Log.defaultSubsystem"
        
        let loggerExpr: String
        let subsystemExpr: String
        if let logger {
            let loggerStr = "\(logger)".replacingOccurrences(of: ".self", with: "")
            loggerExpr = "Logger(subsystem: \(loggerStr).subsystem, category: category)"
            subsystemExpr = "\(loggerStr).subsystem"
        } else {
            loggerExpr = "Logger(subsystem: \(defaultSubsystemExpr), category: category)"
            subsystemExpr = defaultSubsystemExpr
        }
        
        return
            """
            {
                guard Log.Level.Fault >= Log.logLevel else { return }
                let fileName = Log.fileName(from: "\\(#file)")
                let category = "\\(fileName).\\(#function)"
                let message = \(redactedMessage)
                \(raw: loggerExpr).fault(\(message))
                Log.History.add("FAULT  \\(Log.dateFormatter.string(from: Date())) [\\(\(raw: subsystemExpr))] \\(Log.enableVerboseLogging ? "[\\(category)]" : "") \\(message)")
                if Log.enableLiveLogging { LiveLogHistory.shared.add(.fault(subsystem: \(raw: subsystemExpr), message: message)) }
                Log.callMessageHook(message)
                Log.callFaultHook(\(raw: subsystemExpr), message)
            }()
            """
    }
}

public struct LogFatalMacro: ExpressionMacro {
    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        guard let firstArgument = node.arguments.first else {
            throw MacroError.missingArgument
        }
        let message = firstArgument.expression
        return
            """
            Log._injected_logFatal(\(raw: message))
            """
    }
}
