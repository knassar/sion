//
//  SION.swift
//  SION
//
//  Created by Karim Nassar on 5/20/17.
//  Copyright © 2017 Hungry Melon Studio LLC. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//      http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

/** Represents a key in either a SION dictionary or array */
public protocol SIONKey {}
extension String: SIONKey {}
extension Int: SIONKey {}

public struct SION {

    var value: Any? = nil
    var type = ValueType.undefined
    public internal(set) var rawString: String? = nil

    public init() {}

    enum ValueType {
        case array
        case bool
        case date
        case dictionary
        case null
        case number
        case string
        case undefined
    }

    /// an undefined SION value
    public static let undefined = SION(type: .undefined)

    /// a null SION value
    public static let null = SION(type: .null)

    init(type: SION.ValueType, value: Any? = nil) {
        self.value = value
        self.type = type
    }

    /**
     Initialze from a string representation as from a file

     - throws:
     `SION.Error` when parse fails

     - parameters:
        - raw: The string contents of the file or string literal

     */
    public init(raw: String) throws {
        self.rawString = raw
        do {
            let parsed = try Parser.parse(raw)
            self.type = parsed.type
            self.value = parsed.value
        }
        catch let parseError as Parser.Error {
            throw Error.init(parseError: parseError)
        }
    }

    /**
     Initialze from `Data` representation as from a file

     - throws:
     `SION.Error` when decoding or parse fails

     - parameters:
         - data: The data contents of the file
         - encoding: Expected `String.Encoding` to use to decode the `Data`
     */
    public init(data: Data, encoding: String.Encoding = .utf8) throws {
        guard let str = String(data: data, encoding: encoding) else { throw Error.stringFromData }
        try self.init(raw: str)
    }

    // MARK: Identity

    /// isEmpty returns true for `undefined`, `null`, and for empty strings, dictionaries, and arrays
    public var isEmpty: Bool {
        switch type {
        case .undefined, .null,
             .array where (value as? Array ?? []).isEmpty,
             .dictionary where (value as? Dictionary ?? [:]).isEmpty,
             .string where (value as? String ?? "").isEmpty:
            return true
        default:
            return false
        }
    }

    public var isNull: Bool {
        return type == .null
    }

    public var isUndefined: Bool {
        return type == .undefined
    }

    public var isArray: Bool {
        return type == .array && value is [SION]
    }
    
    public var isBool: Bool {
        return type == .bool && value is Bool
    }
    
    public var isDate: Bool {
        return type == .date && value is Date
    }
    
    public var isDictionary: Bool {
        return type == .dictionary && (value is [String: SION] || value is [OrderedKey: SION])
    }

    /// `true` if isArray or isDictionary where key order has been preserved
    public var isOrdered: Bool {
        return isArray || (type == .dictionary && value is [OrderedKey: SION])
    }

    public var isNumber: Bool {
        return type == .number && value is Double
    }
    
    public var isString: Bool {
        return type == .string && value is String
    }
}

