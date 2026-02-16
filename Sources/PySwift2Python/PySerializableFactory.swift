//
//  PySerializableFactory.swift
//  PySwift2Python
//
//  Created by CodeBuilder on 16/02/2026.
//


public struct PySerializableInfo: Hashable {
    let swiftType: String
    let pyType: String
    
    public init(swiftType: String, pyType: String) {
        self.swiftType = swiftType
        self.pyType = pyType
    }
}

final class PySerializableFactory {
    nonisolated(unsafe) static let shared: PySerializableFactory = .init()
    
    var registeredTypes: [String:String] = [:]
    
    init() {
        
    }
    
    static func registerType(_ type: PySerializableInfo) {
        shared.registeredTypes[type.swiftType] = type.pyType
    }
    
    static func registerType(_ swiftType: String, pyType: String) {
        shared.registeredTypes[swiftType] = pyType
    }
    
    static func castType(_ type: String) -> String? {
        shared.registeredTypes[type]
    }
}
