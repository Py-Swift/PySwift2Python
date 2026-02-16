//
//  ClassDef+Exts.swift
//  PySwift2Python
//
import SwiftSyntax
import PySwiftAST

extension PySwiftAST.ClassDef {
    static func from(_ classDecl: ClassDeclSyntax) throws -> Self {
        let className = classDecl.name.text
        let members = classDecl.memberBlock.members
        var body: [Statement] = if members.count > 0 {
            []
        } else {
            [.pass(Pass(lineno: 0, colOffset: 0, endLineno: nil, endColOffset: nil))]
        }
        
        for member in classDecl.memberBlock.members {
            switch member.decl.as(DeclSyntaxEnum.self) {
                case .classDecl(let classDecl):
                    guard classDecl.isPyClass || classDecl.isPyContainer else { continue }
                    //body.append(.blank(2))
                    body.append(.classDef(try .from(classDecl)))
                case .initializerDecl(let initializerDecl):
                    guard initializerDecl.isPyInit else { continue }
                    //body.append(.blank())
                    body.append(.functionDef(initializerDecl.functionDef()))
                case .functionDecl(let functionDecl):
                    guard functionDecl.isPyMethod || functionDecl.isPyCall else { continue }
                    //body.append(.blank())
                    body.append(.functionDef(.from(functionDecl, cls: className)))
                case .variableDecl(let variableDecl):
                    guard variableDecl.isPyProperty else { continue }
                    //body.append(.blank())
                    body.append(contentsOf: try buildPropertyStatements(from: variableDecl))
                    
                default: continue
            }
        }
        
        
        
        return .init(
            name: className,
            body: body
        )
    }
    
    static func from(_ extDecl: ExtensionDeclSyntax, ext_data: PyClassByExtensionUnpack) throws -> Self {
        let className = extDecl.extendedType.trimmedDescription
        let members = extDecl.memberBlock.members
        
        let itemsCount = members.count + ext_data.functions.count  + ext_data.properties.count
        
        var body: [Statement] = if itemsCount > 0 {
            []
        } else {
            [.pass(Pass(lineno: 0, colOffset: 0, endLineno: nil, endColOffset: nil))]
        }
        
        body.append(contentsOf: try ext_data.properties.flatMap(buildPropertyStatements))
        body.append(contentsOf: ext_data.functions.map({.functionDef(.from($0, cls: className))}))
        
        for member in extDecl.memberBlock.members {
            switch member.decl.as(DeclSyntaxEnum.self) {
                case .classDecl(let classDecl):
                    guard classDecl.isPyClass || classDecl.isPyContainer else { continue }
                    //body.append(.blank(2))
                    body.append(.classDef(try .from(classDecl)))
                case .initializerDecl(let initializerDecl):
                    guard initializerDecl.isPyInit else { continue }
                    //body.append(.blank())
                    body.append(.functionDef(initializerDecl.functionDef()))
                case .functionDecl(let functionDecl):
                    guard functionDecl.isPyMethod else { continue }
                    //body.append(.blank())
                    body.append(.functionDef(.from(functionDecl, cls: className)))
                case .variableDecl(let variableDecl):
                    guard variableDecl.isPyProperty else { continue }
                    //body.append(.blank())
                    body.append(contentsOf: try buildPropertyStatements(from: variableDecl))
                    
                default: continue
            }
        }
        
        
        
        return .init(
            name: className,
            body: body
        )
    }
    
    private static func buildPropertyStatements(from varDecl: VariableDeclSyntax) throws -> [Statement] {
        guard let binding = varDecl.bindings.first,
              let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
            throw ParserError.invalidProperty
        }
        
        let propertyName = pattern.identifier.text
        let annotation = binding.typeAnnotation.map(swiftTypeToExpression)
        
        // Determine if property is getter-only or getter+setter
        let propertyType = detectPropertyType(binding: binding, varDecl: varDecl)
        
        var statements: [Statement] = []
        
        // Always create getter
        let getterArgs = Arguments(
            posonlyArgs: [],
            args: [Arg(arg: "self", annotation: nil, typeComment: nil)],
            vararg: nil,
            kwonlyArgs: [],
            kwDefaults: [],
            kwarg: nil,
            defaults: []
        )
        
        let propertyDecorator: Expression = .name(.property)
        
        statements.append(.functionDef(FunctionDef(
            name: propertyName,
            args: getterArgs,
            decoratorList: [propertyDecorator],
            returns: annotation
        )))
        
        // Add setter if property is not getter-only
        if propertyType == .getterAndSetter {
            statements.append(.blank())
            
            let setterArgs = Arguments(
                posonlyArgs: [],
                args: [
                    Arg(arg: "self", annotation: nil, typeComment: nil),
                    Arg(arg: "value", annotation: annotation, typeComment: nil)
                ],
                vararg: nil,
                kwonlyArgs: [],
                kwDefaults: [],
                kwarg: nil,
                defaults: []
            )
            
            // Create @propertyName.setter decorator
            let setterDecorator: Expression = .attribute(Attribute(
                value: .name(.init(id: propertyName)),
                attr: "setter",
                ctx: .load
            ))
            
            statements.append(.functionDef(FunctionDef(
                name: propertyName,
                args: setterArgs,
                decoratorList: [setterDecorator],
                returns: nil
            )))
        }
        
        return statements
    }
    
    /// Detect if property is getter-only or getter+setter
    /// Based on PyFileGenerator logic
    private static func detectPropertyType(binding: PatternBindingSyntax, varDecl: VariableDeclSyntax) -> PropertyType {
        // 1. Check for 'if let' binding → getter only
        if let _ = binding.pattern.as(OptionalBindingConditionSyntax.self) {
            return .getterOnly
        }
        
        // 2. Check if it's 'let' declaration → getter only
        if varDecl.bindingSpecifier.tokenKind == .keyword(.let) {
            return .getterOnly
        }
        
        // 3. Check for computed property with accessors
        if let accessorBlock = binding.accessorBlock {
            switch accessorBlock.accessors {
                case .accessors(let accessors):
                    // Check if there's a setter accessor
                    let hasSetter = accessors.contains { accessor in
                        accessor.accessorSpecifier.tokenKind == .keyword(.set)
                    }
                    return hasSetter ? .getterAndSetter : .getterOnly
                    
                case .getter:
                    // Getter-only computed property
                    return .getterOnly
            }
        }
        
        // 4. Regular 'var' without explicit accessors → getter + setter
        if varDecl.bindingSpecifier.tokenKind == .keyword(.var) {
            return .getterAndSetter
        }
        
        // Default to getter-only for safety
        return .getterOnly
    }
}
