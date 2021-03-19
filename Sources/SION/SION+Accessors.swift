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
            value(forKey: member)
        }
        set(newValue) {
            setValue(newValue, forKey: member)
        }
    }

    public subscript(_ key: String) -> SION {
        get {
            value(forKey: key)
        }
        set(newValue) {
            setValue(newValue, forKey: key)
        }
    }

    // MARK: - Array index

    public subscript(_ index: Int) -> SION {
        get {
            value(forIndex: index)
        }
        set(newValue) {
            setValue(newValue, forIndex: index)
        }
    }

    // MARK: - Subscripts

    internal func value(forKey key: String) -> SION {
        (value as? KeyedContainer)?.value(for: key) ?? .undefined
    }

    mutating internal func setValue(_ newValue: SION, forKey key: String) {
        if isUndefined {
            self.value = KeyedContainer.with(value: newValue, forKey: key)
        } else if var keyed = value as? KeyedContainer {
            keyed.setValue(newValue, forKey: key)
            self.value = keyed
        }
    }

    internal func value(forIndex index: Int) -> SION {
        (value as? UnkeyedContainer)?.value(at: index) ?? .undefined
    }

    mutating internal func setValue(_ newValue: SION, forIndex index: Int) {
        if isUndefined {
            self.value = UnkeyedContainer(values: [newValue])
        } else if var unkeyed = value as? UnkeyedContainer {
            unkeyed.setValue(newValue, at: index)
            self.value = unkeyed
        }
    }

    // MARK: - Value Accessors

    /// The value as a string, or nil
    public var string: String? {
        value as? String
    }

    /// The value as a string, or empty string
    public var stringValue: String {
        string ?? ""
    }

    /// The value as a bool, or nil
    public var bool: Bool? {
        value as? Bool
    }

    /// The value as a bool, or false
    public var boolValue: Bool {
        bool ?? false
    }

    /// The value as a double, or nil
    public var double: Double? {
        (value as? Numeric)?.doubleValue
    }

    /// The value as a double, or 0.0
    public var doubleValue: Double {
        double ?? 0
    }

    /// The value as an integer, or nil
    public var int: Int? {
        (value as? Numeric)?.intValue
    }

    /// The value as an integer, or 0
    public var intValue: Int {
        int ?? 0
    }

    /// The value as a float, or nil
    public var float: Float? {
        guard let double = (value as? Numeric)?.doubleValue else { return  nil }
        return Float(double)
    }

    /// The value as a float, or 0.0
    public var floatValue: Float {
        float ?? 0
    }

    /// The value as a CGFloat, or nil
    public var cgFloat: CGFloat? {
        guard let double = (value as? Numeric)?.doubleValue else { return  nil }
        return CGFloat(double)
    }

    /// The value as a CGFloat, or 0.0
    public var cgFloatValue: CGFloat {
        cgFloat ?? 0
    }

    /// The value as a date, or nil
    public var date: Date? {
        value as? Date
    }

    /// The value as a date, or `Date.distantPast`
    public var dateValue: Date {
        date ?? Date.distantPast
    }

    /// The value as an array, or nil
    public var array: [SION]? {
        (value as? UnkeyedContainer)?.values
    }

    /// The value as an array, or empty array
    public var arrayValue: [SION] {
        array ?? []
    }

    /// The value as a dictionary, or nil. To preserve key order, use `orderedKeyValuePairs` instead.
    public var dictionary: [String: SION]? {
        (value as? KeyedContainer)?.keyValuePairs.reduce(into: [String: SION]()) { $0[$1.key.name] = $1.value }
    }

    /// The value as a dictionary, or empty dictionary. To preserve key order, use `orderedKeyValuePairsValue` instead.
    public var dictionaryValue: [String: SION] {
        dictionary ?? [:]
    }

    /// If it is possible to represent, returns the value as an array of `(String, SION)` tuples, or nil
    public var keyValuePairs: [(String, SION)]? {
        (value as? KeyedContainer)?.keyValuePairs.map { ($0.key.name, $0.value) }
    }

    /// The value as an array of `(String, SION)` tuples, or an empty array
    public var keyValuePairsValue: [(String, SION)]? {
        keyValuePairs ?? []
    }

}

