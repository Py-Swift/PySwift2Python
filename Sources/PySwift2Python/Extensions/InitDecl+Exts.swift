//
//  InitDecl+Exts.swift
//  PySwift2Python
//
import SwiftSyntax
import PySwiftAST

extension InitializerDeclSyntax {
    func functionDef() -> FunctionDef {
        let signature = signature
        var args: [Arg] = []
        
        // Add 'self' parameter
        args.append(._self)
        
        // Add parameters
        for param in signature.parameterClause.parameters {
            let paramName = (param.secondName ?? param.firstName).text
            let annotation = swiftTypeToExpression(param.type)
            
            args.append(Arg(
                arg: paramName,
                annotation: annotation,
                typeComment: nil
            ))
        }
        
        let arguments = Arguments(
            posonlyArgs: [],
            args: args,
            vararg: nil,
            kwonlyArgs: [],
            kwDefaults: [],
            kwarg: nil,
            defaults: []
        )
        
        return FunctionDef(
            name: "__init__",
            args: arguments,
            body: [.pass(Pass(lineno: 0, colOffset: 0, endLineno: nil, endColOffset: nil))],
            decoratorList: [],
            returns: nil,
            typeComment: nil,
            typeParams: [],
            lineno: 0,
            colOffset: 0,
            endLineno: nil,
            endColOffset: nil
        )
    }
}
