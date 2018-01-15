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

    // MARK: - Subscripts

    public subscript(_ keys: SIONKey...) -> SION {
        get {
            return self[keys]
        }
        set(newValue) {
            self[keys] = newValue
        }
    }

    public subscript(_ keys: [SIONKey]) -> SION {
        get {
            var sion = self
            for k in keys {
                sion = sion[k]
            }
            return sion
        }
        set(newValue) {
            guard !keys.isEmpty else { return }
            if keys.count == 1 {
                self[keys[0]] = newValue
            } else {
                var keys = keys
                let key = keys.removeFirst()
                var subexpr = self[key]
                subexpr[keys] = newValue
                self[key] = subexpr
            }
        }
    }

    public subscript(_ key: SIONKey) -> SION {
        get {
            switch type {
            case .array where key is Int:
                let index = key as! Int
                if let a = value as? [SION], index < a.count {
                    return a[index]
                } else {
                    return SION.undefined
                }
            case .dictionary where key is String:
                let key = key as! String
                if let d = value as? [String: SION] {
                    return d[key] ?? SION.undefined
                } else if let d = value as? [OrderedKey: SION] {
                    return d[OrderedKey(key)] ?? SION.undefined
                } else {
                    return SION.undefined
                }
            default:
                return SION.undefined
            }
        }
        set(newValue) {
            switch type {
            case .undefined where key is Int:
                type = .array
                value = [SION]()
                fallthrough
            case .array where key is Int:
                let index = key as! Int
                if var a = value as? [SION] {
                    while a.count <= index {
                        a.append(SION.undefined)
                    }
                    a[index] = newValue
                    value = a
                }
            case .undefined where key is String:
                type = .dictionary
                value = [String: SION]()
                fallthrough
            case .dictionary where key is String:
                let key = key as! String
                if var d = value as? [String: SION] {
                    d[key] = newValue
                    value = d
                } else if var d = value as? [OrderedKey: SION] {
                    d[OrderedKey(key, d.count)] = newValue
                    value = d
                }
            default:
                return
            }
        }
    }

    // MARK: - Value Accessors

    /// The value as a string, or nil
    public var string: String? {
        guard isString else { return nil }
        return value as? String
    }

    /// The value as a string, or empty string
    public var stringValue: String {
        return string ?? ""
    }

    /// The value as a bool, or nil
    public var bool: Bool? {
        guard isBool else { return nil }
        return value as? Bool
    }

    /// The value as a bool, or false
    public var boolValue: Bool {
        return bool ?? false
    }

    /// The value as a double, or nil
    public var number: Double? {
        guard isNumber else { return nil }
        return value as? Double
    }

    /// The value as a double, or 0.0
    public var numberValue: Double {
        return number ?? 0
    }

    /// The value as an integer, or nil
    public var int: Int? {
        guard let double = number else { return nil }
        return Int(double)
    }

    /// The value as an integer, or 0
    public var intValue: Int {
        return int ?? 0
    }

    /// The value as a float, or nil
    public var float: Float? {
        guard let double = number else { return nil }
        return Float(double)
    }

    /// The value as a float, or 0.0
    public var floatValue: Float {
        return float ?? 0
    }

    /// The value as a date, or nil
    public var date: Date? {
        guard isDate else { return nil }
        return value as? Date
    }

    /// The value as a date, or `Date.distantPast`
    public var dateValue: Date {
        return date ?? Date.distantPast
    }

    /// The value as an array, or nil
    public var array: [SION]? {
        guard isArray else { return nil }
        return value as? [SION]
    }

    /// The value as an array, or empty array
    public var arrayValue: [SION] {
        return array ?? []
    }

    /// The value as a dictionary, or nil. To preserve key order, use `orderedKeyValuePairs` instead.
    public var dictionary: [String: SION]? {
        if isDictionary && !isOrdered {
            return value as? [String: SION]
        } else if isDictionary && isOrdered {
            return [String: SION](uniqueKeysWithValues:(value as! [OrderedKey: SION]).map { (k, value) in
                return (k.key, value)
            })
        } else {
            return nil
        }
    }

    /// The value as a dictionary, or empty dictionary. To preserve key order, use `orderedKeyValuePairsValue` instead.
    public var dictionaryValue: [String: SION] {
        return dictionary ?? [:]
    }

    /// If it is possible to represent, returns the value as an array of `(String, SION)` tuples, or nil
    public var keyValuePairs: [(String, SION)]? {
        guard
            isDictionary,
            isOrdered,
            let dictionary = value as? [OrderedKey: SION]
            else { return nil }

        var ordered = [(String, SION)]()
        for key in dictionary.keys.sorted(by: { $0.order < $1.order }) {
            ordered.append((key.key, dictionary[key]!))
        }
        return ordered
    }

    /// The value as an array of `(String, SION)` tuples, or an empty array
    public var keyValuePairsValue: [(String, SION)]? {
        return keyValuePairs ?? []
    }

}

