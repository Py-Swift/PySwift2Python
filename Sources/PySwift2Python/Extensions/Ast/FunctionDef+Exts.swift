//
//  FunctionDef+Exts.swift
//  PySwift2Python
//
import SwiftSyntax
import PySwiftAST


extension PySwiftAST.FunctionDef {
    static func from(_ decl: FunctionDeclSyntax, cls: String? = nil) -> Self {
        let methodName = decl.name.text
        let signature = decl.signature
        var args: [Arg] = []
        var decorators: [Expression] = []
        
        if let _ = cls {
            let isStatic = decl.isStatic
            
            if isStatic {
                decorators.append(.name(.staticmethod))
            } else {
                // Add 'self' parameter for instance methods
                args.append(._self)
            }
        }
        
        for param in signature.parameterClause.parameters {
            let paramName = (param.secondName ?? param.firstName).text
            let annotation = swiftTypeToExpression(param.type)
            
            args.append(Arg(
                arg: paramName,
                annotation: annotation
            ))
        }
        
        let arguments = Arguments(
            args: args
        )
        
        // Parse return type
        let returnType = signature.returnClause.map { returnClause in
            swiftTypeToExpression(returnClause.type)
        }
        
        return .init(
            name: methodName,
            args: arguments,
            decoratorList: decorators,
            returns: returnType,
            typeComment: methodName
        )
    }
}


