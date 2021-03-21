//
//  ASTValue.swift
//  SION
//
//  Created by Karim Nassar on 3/18/21.
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

public protocol ASTValue: CustomDebugStringConvertible {
    var sionValueType: SION.ValueType { get }
    func hash(into hasher: inout Hasher)
}

extension ASTValue {

    func isEqual(to other: ASTValue) -> Bool {
        switch (self, other) {
        case let (me as KeyedContainer, other as KeyedContainer):
            return me == other
        case let (me as UnkeyedContainer, other as UnkeyedContainer):
            return me == other
        case let (me as String, other as String):
            return me == other
        case let (me as Bool, other as Bool):
            return me == other
        case let (me as Date, other as Date):
            return me == other
        case let (me as Numeric, other as Numeric):
            return me == other
        case (is Null, is Null):
            return true
        default:
            return false
        }
    }

}

struct Null: ASTValue {

    let sionValueType = SION.ValueType.null
    let debugDescription = "null"

    func hash(into hasher: inout Hasher) {
        // nothing
    }
}

struct Undefined: ASTValue {
    let sionValueType = SION.ValueType.undefined
    let debugDescription = "<undefined>"

    func hash(into hasher: inout Hasher) {
        // nothing
    }
}

extension String: ASTValue {
    public var sionValueType: SION.ValueType { .string }
}

extension Bool: ASTValue {
    public var sionValueType: SION.ValueType { .bool }

    public var debugDescription: String {
        self ? "true" : "false"
    }
}

extension Date: ASTValue {
    public var sionValueType: SION.ValueType { .date }
}
