//
//  MacroExpansionContext+Extensions.swift
//  LoggingKit
//
//  Created by Denis Esie on 27.11.2025.
//

import SwiftSyntax
import SwiftSyntaxMacros

/// Checks if a type declaration's inheritance clause contains a given protocol name.
/// Note: This only detects direct conformance in the same declaration, not conformances
/// declared in extensions elsewhere.
func declaresConformance(to protocolName: String, in typeSyntax: Syntax?) -> Bool {
    guard let typeSyntax else { return false }
    
    // Extract inheritance clause from different type declarations
    let inheritanceClause: InheritanceClauseSyntax?
    
    if let classDecl = typeSyntax.as(ClassDeclSyntax.self) {
        inheritanceClause = classDecl.inheritanceClause
    } else if let structDecl = typeSyntax.as(StructDeclSyntax.self) {
        inheritanceClause = structDecl.inheritanceClause
    } else if let enumDecl = typeSyntax.as(EnumDeclSyntax.self) {
        inheritanceClause = enumDecl.inheritanceClause
    } else if let actorDecl = typeSyntax.as(ActorDeclSyntax.self) {
        inheritanceClause = actorDecl.inheritanceClause
    } else if let extensionDecl = typeSyntax.as(ExtensionDeclSyntax.self) {
        inheritanceClause = extensionDecl.inheritanceClause
    } else {
        inheritanceClause = nil
    }
    
    guard let inheritanceClause else { return false }
    
    // Check if any inherited type matches the protocol name
    for inheritedType in inheritanceClause.inheritedTypes {
        // Extract the base type, handling attributes like @MainActor
        let baseType: TypeSyntax
        if let attributedType = inheritedType.type.as(AttributedTypeSyntax.self) {
            baseType = attributedType.baseType
        } else {
            baseType = inheritedType.type
        }
        
        // Get the type name from the base type
        let typeName = baseType.trimmedDescription
        if typeName == protocolName {
            return true
        }
    }
    
    return false
}

extension MacroExpansionContext {
    /// Returns the innermost enclosing function (if any) and type (if any)
    /// for the current macro expansion.
    func enclosingFunctionAndType() -> (function: FunctionDeclSyntax?, type: Syntax?) {
        var foundFunction: FunctionDeclSyntax?
        var foundType: Syntax?

        for syntax in lexicalContext {
            // First function we encounter, innermost one
            if foundFunction == nil, let fn = syntax.as(FunctionDeclSyntax.self) {
                foundFunction = fn
                continue
            }

            // First type-like decl we encounter outside that function
            if foundType == nil,
               syntax.is(ClassDeclSyntax.self) ||
               syntax.is(StructDeclSyntax.self) ||
               syntax.is(EnumDeclSyntax.self) ||
               syntax.is(ActorDeclSyntax.self) ||
               syntax.is(ProtocolDeclSyntax.self) ||
               syntax.is(ExtensionDeclSyntax.self) {
                foundType = syntax
            }
        }

        return (foundFunction, foundType)
    }

    func enclosingFunctionTypeAndProperties() -> (function: FunctionDeclSyntax?, type: Syntax?, properties: [VariableDeclSyntax]) {
        var foundFunction: FunctionDeclSyntax?
        var foundType: Syntax?

        for syntax in lexicalContext {
            // First function we encounter, innermost one
            if foundFunction == nil,
               let fn = syntax.as(FunctionDeclSyntax.self) {
                foundFunction = fn
                continue
            }

            // First type-like decl we encounter outside that function
            if foundType == nil,
               syntax.is(ClassDeclSyntax.self) ||
               syntax.is(StructDeclSyntax.self) ||
               syntax.is(EnumDeclSyntax.self) ||
               syntax.is(ActorDeclSyntax.self) ||
               syntax.is(ProtocolDeclSyntax.self) ||
               syntax.is(ExtensionDeclSyntax.self) {
                foundType = syntax
            }
        }

        // Collect properties from the found type (if any)
        var properties: [VariableDeclSyntax] = []

        if let typeSyntax = foundType,
           let declGroup = typeSyntax.asProtocol(DeclGroupSyntax.self) {
            properties = declGroup.memberBlock.members.compactMap { member in
                member.decl.as(VariableDeclSyntax.self)
            }
        }

        return (foundFunction, foundType, properties)
    }
}
