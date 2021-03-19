//
//  SION+Accessors.swift
//  SION
//
//  Created by Karim Nassar on 1/14/18.
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

    // MARK: - Dynamic Member Lookup

    public subscript(dynamicMember member: String) -> SION {
        get {
            return value(forKey: member)
        }
        set(newValue) {
            setValue(newValue, forKey: member)
        }
    }

    public subscript(_ key: String) -> SION {
        get {
            return value(forKey: key)
        }
        set(newValue) {
            setValue(newValue, forKey: key)
        }
    }

    // MARK: - Array index

    public subscript(_ index: Int) -> SION {
        get {
            return value(forIndex: index)
        }
        set(newValue) {
            setValue(newValue, forIndex: index)
        }
    }

    // MARK: - Subscripts

    internal func value(forKey key: String) -> SION {
        switch node.value {
        case let .keyedContainer(keyed):
            return SION(node: keyed.value(for: key) ?? .undefined)
        default:
            return SION.undefined
        }
    }

    mutating internal func setValue(_ newValue: SION, forKey key: String) {
        if isUndefined {
            self.node = AST.KeyedContainer.with(value: newValue.node.value, forKey: key)
        } else if let keyed = node as? AST.KeyedContainer {
            keyed.setValue(newValue.node.value, forKey: key)
        }
    }

    internal func value(forIndex index: Int) -> SION {
        switch node.value {
        case let .unkeyedContainer(unkeyed):
            return SION(node: unkeyed.value(at: index) ?? .undefined)
        default:
            return SION.undefined
        }
    }

    mutating internal func setValue(_ newValue: SION, forIndex index: Int) {
        if isUndefined {
            self.node = AST.UnkeyedContainer.with(newValue.node.value)
        } else if let unkeyed = node as? AST.UnkeyedContainer {
            unkeyed.setValue(newValue.node.value, at: index)
        }
    }

    // MARK: - Value Accessors

    /// The value as a string, or nil
    public var string: String? {
        guard case let .string(value) = (node as? AST.Value)?.value else { return nil }
        return value
    }

    /// The value as a string, or empty string
    public var stringValue: String {
        return string ?? ""
    }

    /// The value as a bool, or nil
    public var bool: Bool? {
        guard case let .bool(value) = (node as? AST.Value)?.value else { return nil }
        return value
    }

    /// The value as a bool, or false
    public var boolValue: Bool {
        return bool ?? false
    }

    /// The value as a double, or nil
    public var double: Double? {
        guard case let .number(value) = (node as? AST.Value)?.value else { return nil }
        return value
    }

    /// The value as a double, or 0.0
    public var doubleValue: Double {
        return double ?? 0
    }

    /// The value as an integer, or nil
    public var int: Int? {
        guard let double = double else { return nil }
        return Int(double)
    }

    /// The value as an integer, or 0
    public var intValue: Int {
        return int ?? 0
    }

    /// The value as a float, or nil
    public var float: Float? {
        guard let double = double else { return nil }
        return Float(double)
    }

    /// The value as a float, or 0.0
    public var floatValue: Float {
        return float ?? 0
    }

    /// The value as a date, or nil
    public var date: Date? {
        guard case let .date(value) = (node as? AST.Value)?.value else { return nil }
        return value
    }

    /// The value as a date, or `Date.distantPast`
    public var dateValue: Date {
        return date ?? Date.distantPast
    }

    /// The value as an array, or nil
    public var array: [SION]? {
        guard case let .unkeyedContainer(value) = (node as? AST.Value)?.value else { return nil }
        return value.values.map { SION(node: $0) }
    }

    /// The value as an array, or empty array
    public var arrayValue: [SION] {
        return array ?? []
    }

    /// The value as a dictionary, or nil. To preserve key order, use `orderedKeyValuePairs` instead.
    public var dictionary: [String: SION]? {
        guard case let .keyedContainer(value) = (node as? AST.Value)?.value else { return nil }
        return value.keyValuePairs.reduce(into: [String: SION]()) { $0[$1.key.name] = SION(node: $1.value) }
    }

    /// The value as a dictionary, or empty dictionary. To preserve key order, use `orderedKeyValuePairsValue` instead.
    public var dictionaryValue: [String: SION] {
        return dictionary ?? [:]
    }

    /// If it is possible to represent, returns the value as an array of `(String, SION)` tuples, or nil
    public var keyValuePairs: [(String, SION)]? {
        guard case let .keyedContainer(value) = (node as? AST.Value)?.value else { return nil }
        return value.keyValuePairs.map { ($0.key.name, SION(node: $0.value)) }
    }

    /// The value as an array of `(String, SION)` tuples, or an empty array
    public var keyValuePairsValue: [(String, SION)]? {
        return keyValuePairs ?? []
    }

}

