

import SwiftSyntax
import SwiftParser
import PySwiftAST
import PathKit

public final class HandleFiles {
    public var py_classes = [ClassDeclSyntax]()
    public var py_classes_ext = [ExtensionDeclSyntax]()
    public var py_containers = [ClassDeclSyntax]()
    public var py_module_structs = [StructDeclSyntax]()
    
    public var outputs: [FileOutput] = []
    
    public init(files: [Path]) throws {
        let decls = files.declSyntax()
        
        for decl in decls {
            switch decl.as(DeclSyntaxEnum.self) {
                case .classDecl(let classDeclSyntax):
                    guard classDeclSyntax.isPyClass else { continue }
                    py_classes.append(classDeclSyntax)
                case .extensionDecl(let extensionDeclSyntax):
                    guard extensionDeclSyntax.isPyClassExt else { continue }
                    py_classes_ext.append(extensionDeclSyntax)
                case .structDecl(let structDeclSyntax):
                    guard structDeclSyntax.isPyModule else { continue }
                    py_module_structs.append(structDeclSyntax)
                default:
                    continue
            }
        }
        
        try processModules()
    }
    
    func processModules() throws {
        for py_module in py_module_structs {
            var included_classes: [ClassDeclSyntax] = []
            var included_classes_ext: [ExtensionDeclSyntax] = []
            for member in py_module.memberBlock.members {
                switch member.decl.as(DeclSyntaxEnum.self) {
                    case .variableDecl(let variableDecl):
                        if let binding = variableDecl.bindings.first {
                            switch binding.initializer?.value.as(ExprSyntaxEnum.self) {
                                case .arrayExpr(let arrayExpr):
                                    switch binding.pattern.as(PatternSyntaxEnum.self) {
                                        case .expressionPattern(let expressionPattern):
                                            break
                                        case .identifierPattern(let identifierPattern):
                                            
                                            guard let infoKey = PyModuleInfoKey(rawValue: identifierPattern.identifier.trimmed.text) else {
                                                break
                                            }
                                            let arrayElements = arrayExpr.elements.compactMap({$0.expression.as(ExprSyntaxEnum.self)})
                                            switch infoKey {
                                                case .py_classes:
                                                    included_classes.append(contentsOf: processPyClasses(arrayElements))
                                                    included_classes_ext.append(contentsOf: processPyClassesExt(arrayElements))
                                                case .py_modules:
                                                    break
                                                case .pyserializableTypes:
                                                    processPyserializableTypes(arrayElements)
                                                        .forEach(PySerializableFactory.registerType)
                                            }
                                        default: break
                                    }
                                default: break
                            }
                        }
                        
                    default: break
                }
            }
            
            let module = try PySwiftAST.Module(
                syntax: py_module,
                classes: included_classes,
                classes_ext: included_classes_ext
            )
            
            outputs.append(
                .init(
                    name: py_module.name.text.camelCaseToSnakeCase(),
                    content: module.description.replacingOccurrences(of: "    ", with: "\t")
                )
            )
        }
    }
    
    private func processPyClasses(_ elements: [ExprSyntaxEnum]) -> [ClassDeclSyntax]{
        return elements.compactMap { element in
            switch element {
                case .memberAccessExpr(let memberAccessExpr):
                    switch memberAccessExpr.base?.as(ExprSyntaxEnum.self) {
                        case .declReferenceExpr(let declReferenceExpr):
                            return py_classes.first { cls in
                                cls.name.trimmedDescription == declReferenceExpr.baseName.text
                            }
                        default: return nil
                    }
                default: return nil
            }
        }
    }
    
    private func processPyClassesExt(_ elements: [ExprSyntaxEnum]) -> [ExtensionDeclSyntax] {
        elements.compactMap { element in
            switch element {
                case .memberAccessExpr(let memberAccessExpr):
                    switch memberAccessExpr.base?.as(ExprSyntaxEnum.self) {
                        case .declReferenceExpr(let declReferenceExpr):
                            return py_classes_ext.first { cls in
                                cls.extendedType.trimmedDescription == declReferenceExpr.baseName.text
                            }
                        default: return nil
                    }
                default: return nil
            }
        }
    }
    
    private func processPyserializableTypes(_ elements: [ExprSyntaxEnum]) -> [PySerializableInfo] {
        elements.compactMap { element in
            switch element {
                case .tupleExpr(let tupleExpr):
                    let tElements = tupleExpr.elements.map(\.expression)
                    if
                        tElements.count == 2,
                        let swiftType = tElements[0].as(MemberAccessExprSyntax.self)?.base?.trimmedDescription,
                        let pyType = tElements[1].as(StringLiteralExprSyntax.self)?.segments.trimmedDescription
                    {
                        return .init(
                            swiftType: swiftType,
                            pyType: pyType
                        )
                    }
                    break
                default: break
            }
            return nil
        }
    }
    
    private func processPyModules() {
        
    }
    
    
}

public struct FileOutput {
    public let name: String
    public let content: String
    
    public init(name: String, content: String) {
        self.name = name
        self.content = content
    }
}


public func handleFiles(files: [Path]) throws -> HandleFiles {
    try .init(files: files)
}
