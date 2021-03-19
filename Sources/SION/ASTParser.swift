//
//  Parser.swift
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

class ASTParser {

    static func parse(_ raw: String) throws -> ASTContainer {
        let p = ASTParser(raw: raw)
        return try p.parseDocument()
    }

    private init(raw: String) {
        self.raw = raw
        self.index = raw.startIndex
    }

    private var raw: String
    private var index: String.Index

    // MARK: - Indexing

    private var thisChar: Character? {
        guard !atEnd else { return nil }
        return raw[index]
    }

    private var thisToken: Token? {
        guard !atEnd else { return nil }
        return Token(rawValue: raw[index])
    }

    private var nextChar: Character? {
        guard !atEnd else { return nil }
        let i = raw.index(after: index)
        guard i != raw.endIndex else { return nil }
        return raw[i]
    }

    private var prevChar: Character? {
        guard !atStart else { return nil }
        let i = raw.index(before: index)
        guard i != raw.startIndex else { return nil }
        return raw[i]
    }

    private var atEnd: Bool {
        return index == raw.endIndex
    }

    private var atStart: Bool {
        return index == raw.startIndex
    }

    private func rewind() {
        index = raw.startIndex
    }

    private func advance() {
        if !atEnd {
            index = raw.index(after: index)
        }
    }

    private func advance(_ number: Int) {
        for _ in 0..<number {
            advance()
        }
    }

    private func peek(_ number: Int) -> String {
        let start = index
        var end = index
        advance(number)
        end = index
        index = start
        return String(raw[start..<end])
    }

    // MARK: - Chomps

    private func chompWhitespace() {
        while let char = thisChar {
            if Token.whitespacesAndNewlines.hasMember(char) {
                advance()
            } else {
                break
            }
        }
    }

    private func chompNonNewlineWhitespace() {
        while let char = thisChar {
            if Token.whitespaces.hasMember(char) {
                advance()
            } else {
                break
            }
        }
    }

    private func chompValueDelim() {
        chompNonNewlineWhitespace()
        if thisToken == .delimVal {
            advance()
            chompNonNewlineWhitespace()
        }
    }

    private func chompIf(matching test: String) -> Bool {
        if peek(test.count).lowercased() == test.lowercased() {
            advance(test.count)
            return true
        } else {
            return false
        }
    }

    private func accumulateWhile(_ test: (Character) -> Bool) -> String {
        let start = index
        while let char = thisChar, test(char) {
            advance()
        }
        return String(raw[start..<index])
    }

}

// MARK: - Error

extension ASTParser {

    enum Error: Swift.Error {
        case none
        case nonDocumentRoot(in: String)
        case syntax(at: String.Index, in: String)
        case invalidKey(at: String.Index, in: String)
        case invalidValue(at: String.Index, in: String)
    }

}

private enum Token: Character {
    case dictOpen = "{"
    case dictClose = "}"
    case arrayOpen = "["
    case arrayClose = "]"
    case quoteSingle = "'"
    case quoteDouble = "\""
    case delimKey = ":"
    case delimVal = ","
    case escape = "\\"
    case fwdSlash = "/"
    case star = "*"

    // token sets
    static let whitespacesAndNewlines = CharacterSet.whitespacesAndNewlines
    static let whitespaces = CharacterSet.whitespaces
    static let newlines = CharacterSet.newlines
    static let valueTerminators = CharacterSet(charactersIn: ",]}")
    static let undelimitedKeyTerminators = CharacterSet(charactersIn: "/:").union(.whitespacesAndNewlines)
    static let numerics = CharacterSet(charactersIn: "0123456789-.")
    // characters that start a literal value:
    static let literals = CharacterSet(charactersIn: "0123456789-.tTfFnN")
}

extension ASTParser {

    private func parseDocument() throws -> ASTContainer {
        let commentsBefore = parseBeforeComments()

        switch try parseValueType() {
        case var .keyedContainer(keyed):
            keyed.commentsBefore = commentsBefore
            chompWhitespace()
            keyed.commentsAfter = parseAfterComments()
            return keyed
        case var .unkeyedContainer(unkeyed):
            unkeyed.commentsBefore = commentsBefore
            chompWhitespace()
            unkeyed.commentsAfter = parseAfterComments()
            return unkeyed
        default:
            throw Error.nonDocumentRoot(in: raw)
        }
    }

    private func parseKeyedContainer() throws -> AST.KeyedContainer {
        let commentsBefore = parseBeforeComments()
        chompWhitespace()
        guard thisToken == .dictOpen else {
            let index = self.index
            throw Error.syntax(at: index, in: raw)
        }
        advance()
        chompWhitespace()
        var kvPairs = [AST.KeyValuePair]()
        while thisToken != .dictClose {
            try kvPairs.append(parseKeyValuePair())
        }
        advance()
        let commentsAfter = parseAfterComments()

        return AST.KeyedContainer(keyValuePairs: kvPairs, commentsBefore: commentsBefore, commentsAfter: commentsAfter)
    }

    private func parseUnkeyedContainer() throws -> AST.UnkeyedContainer {
        let commentsBefore = parseBeforeComments()
        chompWhitespace()
        guard thisToken == .arrayOpen else {
            let index = self.index
            throw Error.syntax(at: index, in: raw)
        }
        advance()
        chompWhitespace()
        var values = [AST.Value]()
        while thisToken != .arrayClose {
            try values.append(parseValue())
        }
        advance()
        let commentsAfter = parseAfterComments()

        return AST.UnkeyedContainer(values: values, commentsBefore: commentsBefore, commentsAfter: commentsAfter)
    }

    private func parseKeyValuePair() throws -> AST.KeyValuePair {
        chompWhitespace()
        let key = try parseKey()
        let value = try parseValue()
        return AST.KeyValuePair(key: key, value: value)
    }

}

// MARK: - Key Parsing

extension ASTParser {

    private func parseKey() throws -> AST.Key {
        let commentsBefore = parseBeforeComments()
        chompWhitespace()
        let name = try parseKeyName()
        chompWhitespace()
        let commentsAfter = parseAfterComments()
        if thisToken == .delimKey {
            advance()
            chompWhitespace()
        }
        return AST.Key(name: name, commentsBefore: commentsBefore, commentsAfter: commentsAfter)
    }

    private func parseKeyName() throws -> String {
        chompWhitespace()
        let endToken: Token
        let keyStartIndex: String.Index
        guard let char = thisChar else { throw Error.invalidKey(at: index, in: raw) }
        switch Token(rawValue: char) {
        case .quoteSingle where !atEnd:
            keyStartIndex = raw.index(after: index)
            endToken = .quoteSingle
        case .quoteDouble where !atEnd:
            keyStartIndex = raw.index(after: index)
            endToken = .quoteDouble
        default:
            keyStartIndex = index
            endToken = .delimKey
        }

        var keyEnd = false
        while !keyEnd, let nextChar = nextChar {
            switch endToken {
            case .quoteSingle, .quoteDouble:
                if Token(rawValue: nextChar) == endToken && thisToken != .escape {
                    keyEnd = true
                }
            case .delimKey:
                if Token.undelimitedKeyTerminators.hasMember(nextChar) {
                    keyEnd = true
                }
            default:
                break
            }
            advance()
        }
        let key = String(raw[keyStartIndex..<index])
        if endToken != .delimKey {
            advance()
        }
        guard !key.isEmpty else { throw Error.invalidKey(at: keyStartIndex, in: raw) }

        return key
    }

}

// MARK: - Value Parsing

extension ASTParser {

    private func parseValue() throws -> AST.Value {
        let commentsBefore = parseBeforeComments()
        chompWhitespace()
        let value = try parseValueType()
        let commentsAfter = parseAfterComments()
        chompWhitespace()
        return AST.Value(value: value, commentsBefore: commentsBefore, commentsAfter: commentsAfter)
    }

    private func parseValueType() throws -> AST.Value.ValueType {
        defer {
            chompValueDelim()
        }
        chompWhitespace()
        guard let char = thisChar else { return .undefined }
        switch Token(rawValue: char) {
        case .dictOpen:
            return try .keyedContainer(parseKeyedContainer())
        case .arrayOpen:
            return try .unkeyedContainer(parseUnkeyedContainer())
        case .quoteSingle:
            return try .string(parseString(.quoteSingle))
        case .quoteDouble:
            return try .string(parseString(.quoteDouble))
        case .delimVal:
            return .undefined
        default:
            if let char = thisChar, Token.literals.hasMember(char) {
                return try parseValueLiteral()
            } else {
                throw Error.syntax(at: index, in: raw)
            }
        }
    }

    private func parseString(_ delim: Token) throws -> String {
        advance()
        let startIndex = index
        guard !atEnd else { throw Error.invalidValue(at: index, in: raw) }
        var valueEnd = false
        while !valueEnd, let nextChar = nextChar {
            if Token(rawValue: nextChar) == delim && thisToken != .escape {
                valueEnd = true
            }
            advance()
        }
        let value = String(raw[startIndex..<index])
        advance()
        return value
    }

    private func parseValueLiteral() throws -> AST.Value.ValueType {
        guard let char = thisChar else { throw Error.invalidValue(at: index, in: raw) }
        switch char {
        case "F" where chompIf(matching: "false"),
             "f" where chompIf(matching: "false"):
            return .bool(false)
        case "T" where chompIf(matching: "true"),
             "t" where chompIf(matching: "true"):
            return .bool(true)
        case "N" where chompIf(matching: "null"),
             "n" where chompIf(matching: "null"):
            return .null
        default:
            if Token.numerics.hasMember(char) {
                let value = accumulateWhile { !Token.valueTerminators.hasMember($0) } .trimmingCharacters(in: Token.whitespacesAndNewlines)
                if let double = Double(value) {
                    return .number(double)
                } else if let date = parseDate(value) {
                    return .date(date)
                }
            }
        }
        // if we can't find a value literal
        throw Error.syntax(at: index, in: raw)
    }

    private struct DateFormatter {
        // TODO: - currently assumes GMT

        // Supports "YYYY-MM-DD HH:mm:ss" and "YYYY/MM/DD HH:mm:ss"
        static var full: ISO8601DateFormatter = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate, .withTime, .withSpaceBetweenDateAndTime, .withColonSeparatorInTime]
            return formatter
        }()

        // Supports "YYYY-MM-DD" and "YYYY/MM/DD"
        static var dateOnly: ISO8601DateFormatter = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]
            return formatter
        }()
    }

    private func parseDate(_ string: String) -> Date? {
        return DateFormatter.full.date(from: string) ?? DateFormatter.dateOnly.date(from: string)
    }

    static func formatDate(_ date: Date) -> String {
        return DateFormatter.full.string(from: date)
    }

}

extension ASTParser {

    private func parseBeforeComments() -> [AST.Comment] {
        chompWhitespace()
        var comments = [AST.Comment]()

        while !atEnd, let token1 = thisToken, let nextChar = nextChar, let token2 = Token(rawValue: nextChar) {

            switch (token1, token2) {
            case (.fwdSlash, .fwdSlash):
                advance(2)
                let comment = AST.Comment.inline(accumulateWhile({ char in
                    !CharacterSet.newlines.hasMember(char)
                }))
                comments.append(comment)
                advance()
            case (.fwdSlash, .star):
                advance(2)
                let comment = AST.Comment.block(accumulateWhile({ _ in
                    peek(2) != "*/"
                }))
                comments.append(comment)
                advance(2)
            default:
                return comments
            }
            chompWhitespace()
        }

        return comments
    }

    private func parseAfterComments() -> [AST.Comment] {
        var comments = [AST.Comment]()
        chompNonNewlineWhitespace()
        while !atEnd, let token1 = thisToken, let nextChar = nextChar, let token2 = Token(rawValue: nextChar) {

            switch (token1, token2) {
            case (.fwdSlash, .fwdSlash):
                advance(2)
                let comment = AST.Comment.inline(accumulateWhile({ char in
                    !CharacterSet.newlines.hasMember(char)
                }))
                comments.append(comment)
                advance()
                return comments
            case (.fwdSlash, .star):
                advance(2)
                let comment = AST.Comment.block(accumulateWhile({ _ in
                    peek(2) != "*/"
                }))
                comments.append(comment)
                advance(2)
                return comments
            default:
                chompWhitespace()
                return comments
            }
        }

        return comments
    }

}
