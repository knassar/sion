//
//  SION+Stringify.swift
//  SION
//
//  Created by Karim Nassar on 5/31/17.
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

/**
 Use to control the behavior of `stringify()`
*/
public struct StringifyOptions: OptionSet {
    public var rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Output valid JSON
    public static let json = StringifyOptions(rawValue: 1 << 0)

    /// Multi-line formatting with indentation
    public static let pretty = StringifyOptions(rawValue: 1 << 1)

    /// do not include a trailing comma after the last element of collections
    public static let noTrailingComma = StringifyOptions(rawValue: 1 << 2)

    /// sort dictionary keys for consistent output
    public static let sortKeys = StringifyOptions(rawValue: 1 << 3)
}

extension SION {

    /**
     Use to serialize a SION structure to a string

     - returns:
     A string representation of the SION data

     - parameters:
        - options: Specifies the behavior of serialization.
    */
    public func stringify(options: StringifyOptions = []) -> String {
        return stringify(options, at: 0)
    }

    func stringify(_ options: StringifyOptions, at depth: Int) -> String {
        switch self.type {
        case .array:
            return stringifyArray(options, at: depth)
        case .bool:
            return stringifyBool(options)
        case .date:
            return stringifyDate(options)
        case .dictionary:
            return stringifyDictionary(options, at: depth)
        case .null:
            return stringifyNull(options)
        case .number:
            return stringifyNumber(options)
        case .string:
            return stringifyString(options)
        case .undefined:
            return stringifyUndefined(options)
        }
    }

    func stringifyArray(_ options: StringifyOptions, at depth: Int) -> String {
        let lPad: String
        let terminator: String
        let bracePad: String
        let braceTerminator: String
        let trailingComma = self.trailingComma(with: options)
        if options.contains(.pretty) {
            bracePad = Pretty.indent(depth)
            lPad = Pretty.indent(depth + 1)
            terminator = ",\n"
            braceTerminator = "\n"
        } else {
            lPad = ""
            bracePad = ""
            terminator = ","
            braceTerminator = ""
        }
        let values = arrayValue.map { lPad + $0.stringify(options, at: depth + 1) } .joined(separator: terminator)
        return "[\(braceTerminator)\(values)\(trailingComma)\(bracePad)]"
    }

    func trailingComma(with options: StringifyOptions) -> String {
        if !isEmpty && options.contains(.pretty) {
            if options.contains(.noTrailingComma) || options.contains(.json) {
                return "\n"
            } else {
                return ",\n"
            }
        } else {
            return ""
        }
    }

    func stringifyBool(_ options: StringifyOptions) -> String {
        return boolValue ? "true" : "false"
    }

    func stringifyDate(_ options: StringifyOptions) -> String {
        let dateString = Parser.formatDate(dateValue)
        return options.contains(.json) ? "\"\(dateString)\"" : dateString
    }

    func stringifyDictionary(_ options: StringifyOptions, at depth: Int) -> String {
        let kvSeparator: String
        let lPad: String
        let kvTerminator: String
        let bracePad: String
        let braceTerminator: String
        let trailingComma = self.trailingComma(with: options)
        if options.contains(.pretty) {
            kvSeparator = ": "
            bracePad = Pretty.indent(depth)
            lPad = Pretty.indent(depth + 1)
            kvTerminator = ",\n"
            braceTerminator = "\n"
        } else {
            kvSeparator = ":"
            lPad = ""
            bracePad = ""
            kvTerminator = ","
            braceTerminator = ""
        }
        var keys: [String]
        if let orderedDictionary = value as? [OrderedKey: SION], !options.contains(.sortKeys) {
            keys = orderedDictionary.keys.sorted { $0.order < $1.order } .map { $0.key }
        } else {
            keys = Array(dictionaryValue.keys)
            if options.contains(.sortKeys) {
                keys = keys.sorted { $0 < $1 }
            }
        }
        let keyValue: [String] = keys.map { key in
            let k = stringifyKey(key, options: options)
            // We know there's a value for every key
            let v = dictionaryValue[key]!.stringify(options, at: depth + 1)
            return "\(lPad)\(k)\(kvSeparator)\(v)"
        }
        return "{\(braceTerminator)\(keyValue.joined(separator: kvTerminator))\(trailingComma)\(bracePad)}"
    }

    func stringifyNull(_ options: StringifyOptions) -> String {
        return "null"
    }

    func stringifyNumber(_ options: StringifyOptions) -> String {
        return "\(numberValue)"
    }

    func stringifyString(_ options: StringifyOptions) -> String {
        let string = stringValue
        if !options.contains(.json) && hasDoubleQuotes(string) && !hasSingleQuotes(string) {
            return "'\(string)'"
        } else {
            return "\"\(escapeDoubleQuotes(string))\""
        }
    }

    func stringifyUndefined(_ options: StringifyOptions) -> String {
        if options.contains(.json) {
            return "null"
        } else {
            return "null /* value undefined */"
        }
    }

    func stringifyKey(_ key: String, options: StringifyOptions) -> String {
        if options.contains(.json) {
            return "\"\(escapeDoubleQuotes(key))\""
        } else if needsQuoted(key) {
            if hasDoubleQuotes(key) && !hasSingleQuotes(key) {
                return "'\(key)'"
            } else {
                return "\"\(escapeDoubleQuotes(key))\""
            }
        } else {
            return key
        }
    }

    struct Matchers {
        static let quoteRequiredChars: CharacterSet = {
            var c = CharacterSet.whitespaces
            c.insert(":")
            return c
        }()
        static let doubleQuote = CharacterSet(charactersIn: "\"")
    }

    struct Pretty {
        static func indent(_ depth: Int) -> String {
            return [String](repeating: "    ", count: depth).joined()
        }
    }

    func needsQuoted(_ string: String) -> Bool {
        return string.rangeOfCharacter(from: Matchers.quoteRequiredChars) != nil
    }

    func hasDoubleQuotes(_ string: String) -> Bool {
        return string.contains("\"")
    }

    func hasSingleQuotes(_ string: String) -> Bool {
        return string.contains("'")
    }

    func escapeDoubleQuotes(_ string: String) -> String {
        var esc = ""
        var index = string.startIndex
        while index != string.endIndex {
            let prev = string[index]
            esc.append(prev)
            index = string.index(after: index)
            if index != string.endIndex {
                let this = string[index]
                if Matchers.doubleQuote.hasMember(this) && prev != "\\" {
                    esc.append("\\")
                }
            }
        }
        return esc
    }

}



