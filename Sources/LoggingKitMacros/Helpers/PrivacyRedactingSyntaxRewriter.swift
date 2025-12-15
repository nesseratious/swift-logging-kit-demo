//
//  PrivacyRedactingSyntaxRewriter.swift
//  swift-logging-kit
//
//  Created by Denis Esie on 15.12.2025.
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
