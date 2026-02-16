//
//  Alias+Exts.swift
//  PySwift2Python
//
import PySwiftAST


extension PySwiftAST.Alias: @retroactive ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(name: value, asName: nil)
    }
}
