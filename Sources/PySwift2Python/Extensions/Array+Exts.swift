//
//  Array+Exts.swift
//  PySwift2Python
//

import SwiftSyntax
import SwiftParser
import PathKit


public extension Array where Element == PathKit.Path {
    
    func statements() -> [CodeBlockItemSyntax.Item] {
        lazy.compactMap(\.fileSyntax).compactMap({ file -> [CodeBlockItemSyntax.Item] in
            file.statements.map(\.item)
        }).flatMap(\.self)
    }
    
    func declSyntax() -> [DeclSyntax] {
        statements().compactMap { member in
            switch member {
                case .decl(let declSyntax):
                    switch declSyntax.as(DeclSyntaxEnum.self) {
                        case .classDecl(let classDecl):
                            if classDecl.isPyClass {
                                return .init(classDecl)
                            }
                        case .structDecl(let structDecl):
                            if structDecl.isPyModule {
                                return .init(structDecl)
                            }
                        case .extensionDecl(let extensionDecl):
                            if extensionDecl.isPyClassExt {
                                return .init(extensionDecl)
                            }
                        default: break
                    }
                case .stmt(let stmtSyntax):
                    break
                case .expr(let exprSyntax):
                    break
            }
            return nil
        }
    }
    
}


