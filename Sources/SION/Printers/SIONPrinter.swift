//
//  SIONPrinter.swift
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

class SIONPrinter: Printer {

    let options: StringifyOptions

    private(set) var depth = 0
    private var currentPath = ""

    required init(options: StringifyOptions) {
        self.options = options
    }

    func print(_ node: ASTWrappableNode) -> String {
        let content: [String] =
                node.commentsBefore.map { self.printComment($0) } +
                [printNode(node)] +
                node.commentsAfter.map { self.printComment($0) }

        return content.joined(separator: "\n")
    }

    private func printNode(_ node: ASTWrappableNode) -> String {
        switch node.value {
        case let .unkeyedContainer(unkeyed):
            return printUnkeyedContainer(unkeyed)
        case let .keyedContainer(keyed):
            return printKeyedContainer(keyed)
        case let .bool(bool):
            return print(bool)
        case let .date(date):
            return print(date)
        case .null:
            return printNull()
        case let .number(number):
            return print(number)
        case let .string(string):
            return print(string)
        case .undefined:
            return ""
        }
    }

    func printUnkeyedContainer(_ unkeyed: AST.UnkeyedContainer) -> String {
        let lEnd = lineEnd()

        var values = [String]()
        depth += 1
        for i in 0..<unkeyed.values.count {
            values.append(printValue(unkeyed.values[i], last: unkeyed.values.count - 1 == i, isStandAloneLine: true))
        }
        depth -= 1

        return ["[", values.joined(separator: lEnd), indent() + "]"].joined(separator: lEnd)
    }

    func printValue(_ node: AST.Value, last: Bool, isStandAloneLine: Bool) -> String {
        let lEnd = lineEnd()
        let spc = space()
        let lPad = isStandAloneLine ? indent() : ""

        let separator = last ? trailingSeparator : valueSeparator
        let valueString = printNode(node) + separator

        if options.includeComments {
            let before = node.commentsBefore.map { printComment($0) }
            let after = node.commentsAfter.map { printComment($0) }
            let valueAndTrailingComment = valueString + spc + after.joined(separator: spc)
            return (before + [valueAndTrailingComment]).map {
                lPad + trimTrailingSpaces($0)
            }.joined(separator: lEnd)
        } else {
            return lPad + valueString
        }
    }

    func printKeyedContainer(_ keyed: AST.KeyedContainer) -> String {
        let lEnd = lineEnd()

        depth += 1
        let keyPairs = options.contains(.sortKeys) ? keyed.keyValuePairs.sorted() : keyed.keyValuePairs
        let lines = keyPairs.map { printEntryForKeyValuePair($0, last: $0 == keyPairs.last) }.joined(separator: lEnd)
        depth -= 1

        return ["{", lines, indent() + "}"].joined(separator: lEnd)
    }

    func printEntryForKeyValuePair(_ keypair: AST.KeyValuePair, last: Bool) -> String {
        let spc = space()

        return printKey(keypair.key) + ":" + spc + printValue(keypair.value, last: last, isStandAloneLine: false)
    }

    func printKey(_ key: AST.Key) -> String {
        let lPad = indent()
        let lEnd = lineEnd()
        let spc = space()

        let printedKey: String
        if needsQuoted(key.name) {
            if hasDoubleQuotes(key.name) && !hasSingleQuotes(key.name) {
                printedKey = "'\(key.name)'"
            } else {
                printedKey = "\"\(escapeDoubleQuotes(key.name))\""
            }
        } else {
            printedKey = key.name
        }

        if options.includeComments {
            let before = key.commentsBefore.map { printComment($0) }
            let after = key.commentsAfter.map { printComment($0) }
            return (before + [printedKey + spc] + after).map { lPad + trimTrailingSpaces($0) }.joined(separator: lEnd)
        } else {
            return lPad + printedKey
        }
    }

//    func printIndentComment(_ comment: Comment) -> String {
//        let lEnd = lineEnd()
//        let lPad = indent()
//
//        switch comment.style {
//        case .some(.line):
//            return printComment(comment)
//        case .none where comment.isSingleLine:
//            return lPad + printComment(comment)
//        case .some(.block), .none:
//            return lPad + printComment(comment).replacingOccurrences(of: lEnd, with: lEnd + lPad)
//        }
//    }

    func printComment(_ comment: AST.Comment) -> String {
        guard options.includeComments else { return "" }
        switch comment {
        case let .inline(text):
            return "//" + text
        case let .block(text):
            return "/*" + text + "*/"
        }
    }

    var valueSeparator: String {
        return ","
    }

    var trailingSeparator: String {
        return options.contains(.noTrailingComma) ? "" : valueSeparator
    }

    func trimTrailingSpaces(_ string: String) -> String {
        var string = string
        while string.last == " " {
            string = String(string.dropLast())
        }
        return string
    }

}
