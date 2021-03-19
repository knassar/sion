//
//  File.swift
//  
//
//  Created by Karim Nassar on 3/19/21.
//

import Foundation

extension SION {

    /// isEmpty returns true for `undefined`, `null`, and for empty strings, dictionaries, and arrays
    public var isEmpty: Bool {
        switch value {
        case let container as ASTContainer:
            return container.isEmpty

        case let string as String:
            return string.isEmpty

        default:
            switch type {
            case .undefined, .null:
                return true
            default:
                return false
            }
        }
    }

    public var isNull: Bool {
        type == .null
    }

    public var isUndefined: Bool {
        type == .undefined
    }

    public var isArray: Bool {
        type == .unkeyedContainer
    }

    public var isBool: Bool {
        type == .bool
    }

    public var isDate: Bool {
        type == .date
    }

    public var isDictionary: Bool {
        type == .keyedContainer
    }

    public var isNumber: Bool {
        type == .number
    }

    public var isString: Bool {
        type == .string
    }

}
