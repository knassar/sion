//
//  SION+Identity.swift
//  SION
//
//  Created by Karim Nassar on 3/19/21.
//  Copyright © 2018 Hungry Melon Studio LLC. All rights reserved.
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

extension SION {

    /// returns true for `undefined`, `null`, and for empty strings, dictionaries, and arrays
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
