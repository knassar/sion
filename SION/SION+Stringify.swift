//
//  SION+Stringify.swift
//  SION
//
//  Created by Karim Nassar on 5/31/17.
//  Copyright © 2017 HungryMelonStudios LLC. All rights reserved.
//

import Foundation

extension SION {
    
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

    public func stringify(_ options: StringifyOptions = []) -> String {
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
        let trailingComma: String
        if options.contains(.pretty) {
            bracePad = Pretty.indent(depth)
            lPad = Pretty.indent(depth + 1)
            terminator = ",\n"
            braceTerminator = "\n"
            if options.contains(.noTrailingComma) || options.contains(.json) {
                trailingComma = "\n"
            }
            else {
                trailingComma = terminator
            }
        }
        else {
            lPad = ""
            bracePad = ""
            terminator = ","
            braceTerminator = ""
            trailingComma = ""
        }
        let values = arrayValue.map { lPad + $0.stringify(options, at: depth + 1) } .joined(separator: terminator)
        return "\(bracePad){\(braceTerminator)\(values)\(trailingComma)\(braceTerminator)\(bracePad)}"
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
        let trailingComma: String
        if options.contains(.pretty) {
            kvSeparator = ": "
            bracePad = Pretty.indent(depth)
            lPad = Pretty.indent(depth + 1)
            kvTerminator = ",\n"
            braceTerminator = "\n"
            if options.contains(.noTrailingComma) || options.contains(.json) {
                trailingComma = "\n"
            }
            else {
                trailingComma = kvTerminator
            }
        }
        else {
            kvSeparator = ":"
            lPad = ""
            bracePad = ""
            kvTerminator = ","
            braceTerminator = ""
            trailingComma = ""
        }
        var keys = Array(dictionaryValue.keys)
        if options.contains(.sortKeys) {
            keys = keys.sorted { $0 < $1 }
        }
        let keyValue: [String] = keys.map { key in
            let k = stringifyKey(key, options: options)
            let v = dictionaryValue[key]?.stringify(options, at: depth + 1) ?? stringifyUndefined(options)
            return "\(lPad)\(k)\(kvSeparator)\(v)"
        }
        return "\(bracePad){\(braceTerminator)\(keyValue.joined(separator: kvTerminator))\(trailingComma)\(bracePad)}"
    }
    
    func stringifyNull(_ options: StringifyOptions) -> String {
        return "null"
    }
    
    func stringifyNumber(_ options: StringifyOptions) -> String {
        return "\(numberValue)"
    }
    
    func stringifyString(_ options: StringifyOptions) -> String {
        let string = stringValue
        if options.contains(.json) || hasMixedQuotes(string) {
            return "\"\(escapeDoubleQuotes(string))\""
        }
        else if hasDoubleQuotes(string) && !hasSingleQuotes(string) {
            return "'\(string)'"
        }
        else {
            return "\"\(string)\""
        }
    }

    func stringifyUndefined(_ options: StringifyOptions) -> String {
        return "null"
    }
    
    func stringifyKey(_ key: String, options: StringifyOptions) -> String {
        if options.contains(.json) {
            return "\"\(escapeDoubleQuotes(key))\""
        }
        else if needsQuoted(key) {
            if hasMixedQuotes(key) {
                return "\"\(escapeDoubleQuotes(key))\""
            }
            else if hasDoubleQuotes(key) {
                return "'\(key)'"
            }
            else {
                return "\"\(key)\""
            }
        }
        else {
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
        static let singleQuote = CharacterSet(charactersIn: "'")
    }
    
    struct Pretty {
        static func indent(_ depth: Int) -> String {
            return [String](repeating: "    ", count: depth).joined()
        }
    }
    
    func needsQuoted(_ string: String) -> Bool {
        return string.rangeOfCharacter(from: Matchers.quoteRequiredChars) != nil
    }

    func hasMixedQuotes(_ string: String) -> Bool {
        return hasDoubleQuotes(string) && hasSingleQuotes(string)
    }

    func hasDoubleQuotes(_ string: String) -> Bool {
        return string.replacingOccurrences(of: "\\\"", with: "").rangeOfCharacter(from: Matchers.doubleQuote) != nil
    }

    func hasSingleQuotes(_ string: String) -> Bool {
        return string.replacingOccurrences(of: "\\'", with: "").rangeOfCharacter(from: Matchers.singleQuote) != nil
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



