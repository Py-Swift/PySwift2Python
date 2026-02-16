//
//  PyTypes.swift
//  PySwift2Python
//
import PySwiftAST


enum PyTypes: String {
    case String, Substring
    case Int, Int64, Int32, Int16, Int8
    case UInt, UInt64, UInt32, UInt16, UInt8
    case Double, Float, Float32, Float16, CGFloat
    case Bool
    case Data
    case Date, DateComponents
    case URL
    case Void
    case _Void = "()"
    case PyPointer
    
    var pyType: String {
        switch self {
            case .String, .Substring: "str"
            case .Int, .Int64, .Int32, .Int16, .Int8: "int"
            case .UInt, .UInt64, .UInt32, .UInt16, .UInt8: "int"
            case .Double, .Float, .Float32, .Float16, .CGFloat: "float"
            case .Bool: "bool"
            case .Data: "bytes"
            case .Date, .DateComponents: "datetime.datetime"
            case .URL: "str"
            case .Void, ._Void: "None"
            case .PyPointer: "object"
        }
    }
    
    var nameExpr: Expression {
        .name(Name(
            id: pyType
        ))
    }
    
}
