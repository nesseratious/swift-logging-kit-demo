//
//  CalendarsSwiftBuildtoolsMacros.swift
//  swift-logging-kit
//
//  Created by Denis Esie on 15.12.2025.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

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
        LogFatalMacro.self,
    ]
}
