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

@dynamicMemberLookup
public struct SION {

    var node: ASTWrappableNode
    public internal(set) var rawString: String? = nil

    init() {
        self.node = AST.Value.undefined
    }

    /// an undefined SION value
    public static let undefined = SION(node: AST.Value.undefined)

    /// a null SION value
    public static let null = SION(node: AST.Value.null)

    init(node: ASTWrappableNode) {
        self.node = node
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
            self.node = try ASTParser.parse(raw)
        }
        catch let parseError as ASTParser.Error {
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
        switch node {
        case let container as ASTContainer:
            return container.isEmpty

        case let value as AST.Value:
            switch value.value {
            case .undefined, .null:
                return true
            case let .string(string):
                return string.isEmpty
            default:
                return false
            }
        default:
            return false
        }
    }

    public var isNull: Bool {
        return (node as? AST.Value) == AST.Value.null
    }

    public var isUndefined: Bool {
        switch node.value {
        case .undefined:
            return true
        default:
            return false
        }
    }

    public var isArray: Bool {
        return node is AST.UnkeyedContainer
    }
    
    public var isBool: Bool {
        switch (node as? AST.Value)?.value {
        case .bool:
            return true
        default:
            return false
        }
    }
    
    public var isDate: Bool {
        switch (node as? AST.Value)?.value {
        case .date:
            return true
        default:
            return false
        }
    }
    
    public var isDictionary: Bool {
        return node is AST.KeyedContainer
    }

    public var isNumber: Bool {
        switch (node as? AST.Value)?.value {
        case .number:
            return true
        default:
            return false
        }
    }
    
    public var isString: Bool {
        switch (node as? AST.Value)?.value {
        case .string:
            return true
        default:
            return false
        }
    }

}
