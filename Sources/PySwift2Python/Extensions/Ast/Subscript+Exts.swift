//
//  Subscript+Exts.swift
//  PySwift2Python
//
import PySwiftAST

extension PySwiftAST.Subscript {
    static func tuple(
        elts: [Expression],
        ctx: ExprContext = .load,
        lineno: Int = 0,
        colOffset: Int = 0,
        endLineno: Int? = nil,
        endColOffset: Int? = nil
    ) -> Self {
        return .init(
            value: .name("tuple"),
            slice: .tuple(Tuple(
                elts: elts,
                ctx: .load,
                lineno: 0,
                colOffset: 0,
                endLineno: nil,
                endColOffset: nil
            )),
            ctx: ctx,
            lineno: lineno,
            colOffset: colOffset,
            endLineno: endLineno,
            endColOffset: endColOffset
        )
    }
    
    static func callable(
        args: [Expression],
        returns: Expression? = nil,
        ctx: ExprContext = .load,
        lineno: Int = 0,
        colOffset: Int = 0,
        endLineno: Int? = nil,
        endColOffset: Int? = nil
    ) -> Self {
        
        return .init(
            value: .name("Callable"),
            slice: .list([
                .list(.init(args)),
                returns ?? .name(.None)
            ]),
            ctx: ctx,
            lineno: 0,
            colOffset: 0,
            endLineno: nil,
            endColOffset: nil
        )
    }
    
    static func set(
        type: Expression,
        ctx: ExprContext = .load,
        lineno: Int = 0,
        colOffset: Int = 0,
        endLineno: Int? = nil,
        endColOffset: Int? = nil
    ) -> Self {
        
        return .init(
            value: .name("set"),
            slice: type,
            ctx: ctx,
            lineno: 0,
            colOffset: 0,
            endLineno: nil,
            endColOffset: nil
        )
    }
}

