//
//  Printer.swift
//  SION
//
//  Created by Karim Nassar on 1/21/19.
//  Copyright © 2019 HungryMelonStudios LLC. All rights reserved.
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

protocol Printer {

    var options: StringifyOptions { get }
    var depth: Int { get }

    func print(_ sion: ASTWrappableNode) throws -> String

    init(options: StringifyOptions)
}

extension Printer {

    // MARK: - Value prints

    func print(_ boolValue: Bool) -> String {
        return boolValue ? "true" : "false"
    }

    func print(_ dateValue: Date) -> String {
        let dateString = ASTParser.formatDate(dateValue)
        return options.contains(.json) ? "\"\(dateString)\"" : dateString
    }

    func printNull() -> String {
        return "null"
    }

    func print(_ doubleValue: Double) -> String {
        return "\(doubleValue)"
    }

    func print(_ stringValue: String) -> String {
        if !options.contains(.json) && hasDoubleQuotes(stringValue) && !hasSingleQuotes(stringValue) {
            return "'\(stringValue)'"
        } else {
            return "\"\(escapeDoubleQuotes(stringValue))\""
        }
    }

    // MARK: - Utility

    func needsQuoted(_ string: String) -> Bool {
        return string.rangeOfCharacter(from: PrintMatcher.quoteRequiredChars) != nil
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
                if PrintMatcher.doubleQuote.hasMember(this) && prev != "\\" {
                    esc.append("\\")
                }
            }
        }
        return esc
    }

    func indent() -> String {
        guard options.contains(.pretty) else {
            return ""
        }
        return [String](repeating: "    ", count: depth).joined()
    }

    func space() -> String {
        guard options.contains(.pretty) else {
            return ""
        }
        return " "
    }

    func lineEnd() -> String {
        guard options.contains(.pretty) else {
            return ""
        }
        return "\n"
    }

}

private struct PrintMatcher {

    static let quoteRequiredChars: CharacterSet = {
        var c = CharacterSet.whitespaces
        c.insert(":")
        return c
    }()

    static let doubleQuote = CharacterSet(charactersIn: "\"")

}
