//
//  PathKit+Exts.swift
//  PySwift2Python
//
import PathKit
import SwiftSyntax
import SwiftParser

extension PathKit.Path {
    var fileSyntax: SourceFileSyntax? {
        guard exists, self.extension == "swift" else { return nil }
        return Parser.parse(source: try! read())
    }
}
