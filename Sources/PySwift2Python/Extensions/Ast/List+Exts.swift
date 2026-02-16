//
//  List+Exts.swift
//  PySwift2Python
//
import PySwiftAST

extension PySwiftAST.List: @retroactive ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: PySwiftAST.Expression...) {
        self.init(elts: elements, ctx: .load, lineno: 0, colOffset: 0, endLineno: nil, endColOffset: nil)
    }
    
    public init(_ elements: [PySwiftAST.Expression]) {
        self.init(elts: elements, ctx: .load, lineno: 0, colOffset: 0, endLineno: nil, endColOffset: nil)
    }
}
