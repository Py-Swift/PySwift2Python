//
//  SwiftTypesToExpr.swift
//  PySwift2Python
//
import PySwiftAST
import SwiftSyntax
import SwiftParser


func swiftTypeToExpression(_ type: TypeSyntax) -> Expression {
    
    switch type.as(TypeSyntaxEnum.self) {
        case .arrayType(let arrayTypeSyntax):
            return swiftArrayToExpression(arrayTypeSyntax)
        case .attributedType(let attributedTypeSyntax):
            break
        case .classRestrictionType(let classRestrictionTypeSyntax):
            break
        case .compositionType(let compositionTypeSyntax):
            break
        case .dictionaryType(let dictionaryTypeSyntax):
            return swiftDictToExpression(dictionaryTypeSyntax)
        case .functionType(let functionTypeSyntax):
            break
        case .identifierType(let identifierTypeSyntax):
            return swiftIdentifierToExpression(identifierTypeSyntax)
        case .implicitlyUnwrappedOptionalType(let implicitlyUnwrappedOptionalTypeSyntax):
            break
        case .memberType(let memberTypeSyntax):
            break
        case .metatypeType(let metatypeTypeSyntax):
            break
        case .missingType(let missingTypeSyntax):
            break
        case .namedOpaqueReturnType(let namedOpaqueReturnTypeSyntax):
            break
        case .optionalType(let optionalTypeSyntax):
            return swiftOptionalToExpression(optionalTypeSyntax)
        case .packElementType(let packElementTypeSyntax):
            break
        case .packExpansionType(let packExpansionTypeSyntax):
            break
        case .someOrAnyType(let someOrAnyTypeSyntax):
            break
        case .suppressedType(let suppressedTypeSyntax):
            break
        case .tupleType(let tupleTypeSyntax):
            break
    }
    
    // Default to "object"
    return .name(Name(
        id: "object"
    ))
}

func swiftTypeToExpression(_ annotation: TypeAnnotationSyntax) -> Expression {
    swiftTypeToExpression(annotation.type)
}


fileprivate func swiftOptionalToExpression(_ type: OptionalTypeSyntax) -> Expression {
    return .subscriptExpr(Subscript(
        value: .name("Optional"),
        slice: swiftTypeToExpression(type.wrappedType)
    ))
}

fileprivate func swiftIdentifierToExpression(_ type: IdentifierTypeSyntax) -> Expression {
    let typeName = type.name.text
    
    if let pythonType = PyTypes(rawValue: typeName)?.nameExpr {
        return pythonType
    }
    let typeTrimmed = type.trimmedDescription
    
    if let castType = PySerializableFactory.castType(typeTrimmed) {
        //return .constant(.init(value: .string(castType), kind: nil, lineno: 0, colOffset: 0, endLineno: nil, endColOffset: nil))
        return .name(.init(stringLiteral: castType))
    }
    
    if typeName == "Set", let genericArgs = type.genericArgumentClause?.arguments  {
        
        let elts = genericArgs.map { genericArg in
            switch genericArg.argument {
                case .type(let gType):
                    return swiftTypeToExpression(gType)
                default:
                    return .name("object")
            }
        }
        if let first = elts.first {
            return .subscriptExpr(.set(type: first))
        }
    }
    
    return typeName.constant
}

fileprivate func swiftArrayToExpression(_ type: ArrayTypeSyntax) -> Expression {
    let elementType = swiftTypeToExpression(type.element)
    
    // Create list[element_type] subscript expression
    return .subscriptExpr(Subscript(
        value: .name("list"),
        slice: elementType
    ))
}

fileprivate func swiftDictToExpression(_ type: DictionaryTypeSyntax) -> Expression {
    let keyType = swiftTypeToExpression(type.key)
    let valueType = swiftTypeToExpression(type.value)
    
    // Create dict[key_type, value_type] subscript expression
    let tupleElts = [keyType, valueType]
    return .subscriptExpr(Subscript(
        value: .name("dict"),
        slice: .tuple(Tuple(elts: tupleElts))
    ))
}


fileprivate func swiftTupleToExpression(_ type: TupleTypeSyntax) -> Expression {
    let elements = type.elements
    
    switch elements.count {
        case 1:
            return swiftTypeToExpression(elements.first!.type)
        default:
            let elementTypes = elements.map { element in
                swiftTypeToExpression(element.type)
            }
            return .subscriptExpr(.tuple(elts: elementTypes))
    }
}

fileprivate func functionTypeToExpression(_ type: FunctionTypeSyntax) -> Expression {
    let args = type.parameters.map { element in
        swiftTypeToExpression(element.type)
    }
    let rtns = swiftTypeToExpression(type.returnClause.type)
    return .subscriptExpr(
        .callable(
            args: args,
            returns: rtns
        )
    )
}




