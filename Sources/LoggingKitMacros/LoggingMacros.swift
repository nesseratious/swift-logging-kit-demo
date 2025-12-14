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

// MARK: - Privacy Redaction Helper

/// Rewrites string interpolations with privacy annotations.
/// If privacy is `.public`, removes the privacy argument.
/// If privacy is anything else, replaces the interpolation with `<redacted>`.
final class PrivacyRedactingSyntaxRewriter: SyntaxRewriter {
    override func visit(_ node: StringLiteralExprSyntax) -> ExprSyntax {
        var newSegments: [StringLiteralSegmentListSyntax.Element] = []
        
        for segment in node.segments {
            if case .expressionSegment(let exprSegment) = segment {
                // Check if this interpolation has a privacy argument
                if let privacyArg = exprSegment.expressions.first(where: { $0.label?.text == "privacy" }) {
                    let privacyValue = privacyArg.expression.description.trimmingCharacters(in: CharacterSet.whitespaces)
                    
                    if privacyValue == ".public" {
                        // Keep the interpolation but remove the privacy argument
                        let filteredExpressions = exprSegment.expressions.filter { $0.label?.text != "privacy" }
                        let newExprSegment = exprSegment.with(\.expressions, LabeledExprListSyntax(filteredExpressions.map { $0 }))
                        newSegments.append(.expressionSegment(newExprSegment))
                    } else {
                        // Replace with <redacted>
                        let redactedSegment = StringSegmentSyntax(content: .stringSegment("<redacted>"))
                        newSegments.append(.stringSegment(redactedSegment))
                    }
                } else {
                    // No privacy argument, keep as-is
                    newSegments.append(segment)
                }
            } else {
                // Regular string segment, keep as-is
                newSegments.append(segment)
            }
        }
        
        let newNode = node.with(\.segments, StringLiteralSegmentListSyntax(newSegments))
        return ExprSyntax(newNode)
    }
}

/// Processes the message expression to redact private interpolations.
func redactPrivateInterpolations(in expression: ExprSyntax) -> ExprSyntax {
    let rewriter = PrivacyRedactingSyntaxRewriter(viewMode: .sourceAccurate)
    return rewriter.rewrite(expression).as(ExprSyntax.self) ?? expression
}

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
                Log.callCriticalHook(\(raw: subsystemExpr), message)
            }()
            """
    }
}

enum MacroError: Error {
    case missingArgument
}

@main
struct CalendarsSwiftBuildtoolsMacros: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        LogTraceMacro.self,
        LogDebugMacro.self,
        LogInfoMacro.self,
        LogUserEventMacro.self,
        LogPerformanceMacro.self,
        LogSuccessMacro.self,
        LogNoticeMacro.self,
        LogWarningMacro.self,
        LogErrorMacro.self,
        LogCriticalMacro.self,
        LogFaultMacro.self,
    ]
}
