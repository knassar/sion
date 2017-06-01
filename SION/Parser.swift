//
//  Parser.swift
//  SION
//
//  Created by Karim Nassar on 5/20/17.
//  Copyright © 2017 HungryMelonStudios LLC. All rights reserved.
//

import Foundation

class Parser {

    static func parse(_ raw: String) throws -> SION {
        let p = Parser(raw: raw)
        try p.start()
        return p.sion
    }
    
    static func value(from raw: String, at start: String.Index) throws -> (value: SION, index: String.Index) {
        let p = Parser(raw: raw)
        p.index = start
        try p.start()
        return (p.sion, p.index)
    }
    
    init(raw: String) {
        self.raw = raw
        self.index = raw.startIndex
    }
    
    private(set) public var sion = SION()
    private(set) public var error = Error.none
    private var raw: String
    private var index: String.Index

    // MARK: - Indexing
    
    var thisChar: Character? {
        guard !atEnd else { return nil }
        return raw[index]
    }
    
    var nextChar: Character? {
        guard !atEnd else { return nil }
        let i = raw.index(after: index)
        guard i != raw.endIndex else { return nil }
        return raw[i]
    }
    
    var prevChar: Character? {
        guard !atStart else { return nil }
        let i = raw.index(before: index)
        guard i != raw.startIndex else { return nil }
        return raw[i]
    }
    
    var atEnd: Bool {
        return index == raw.endIndex
    }
    
    var atStart: Bool {
        return index == raw.startIndex
    }
    
    func rewind() {
        index = raw.startIndex
    }
    
    func advance() {
        if !atEnd {
            index = raw.index(after: index)
        }
    }

    func advance(_ number: Int) {
        for _ in 0..<number {
            advance()
        }
    }

    func peek(_ number: Int) -> String {
        let start = index
        var end = index
        advance(number)
        end = index
        index = start
        return raw.substring(with: start..<end)
    }
    
    // MARK: - Chomps
    
    func chompLineComment() {
        while let char = thisChar, !Token.newlines.hasMember(char) {
            advance()
        }
        advance()
    }
    
    func chompBlockComment() {
        while !(thisChar == Token.star && nextChar == Token.fwdSlash) {
            advance()
        }
        advance(2)
    }
    
    func chompWhitespace() {
        while let char = thisChar {
            if char == Token.fwdSlash && nextChar == Token.fwdSlash {
                chompLineComment()
            }
            else if char == Token.fwdSlash && nextChar == Token.star {
                chompBlockComment()
            }
            else if Token.whitespaces.hasMember(char) {
                advance()
            }
            else {
                break
            }
        }
    }

    func chompValueDelim() {
        chompWhitespace()
        if thisChar == Token.delimVal {
            advance()
            chompWhitespace()
        }
    }
    
    func chompIf(matching test: String) -> Bool {
        if peek(test.characters.count).lowercased() == test.lowercased() {
            advance(test.characters.count)
            return true
        }
        else {
            return false
        }
    }
    
    func accumulateWhile(_ test: (Character) -> Bool) -> String {
        let start = index
        while let char = thisChar, test(char) {
            advance()
        }
        return raw.substring(with: start..<index)
    }
    
    // MARK: - Error
    
    enum Error: Swift.Error {
        case none
        case syntax(at: String.Index, in: String)
        case invalidKey(at: String.Index, in: String)
        case invalidValue(at: String.Index, in: String)
    }
    
    // MARK: - Parse
    
    func start() throws {
        guard !self.raw.isEmpty else { return }
        chompWhitespace()
        try parseToType()
    }

    func parseToType() throws {
        chompWhitespace()
        guard let char = thisChar else { return }
        switch char {
        case Token.dictOpen:
            sion.type = .dictionary
            advance()
            sion.value = try parseDictionary()
        case Token.arrayOpen:
            sion.type = .array
            advance()
            sion.value = try parseArray()
        case Token.quoteSingle, Token.quoteDouble:
            sion.type = .string
            sion.value = try parseString(char)
        case Token.delimVal:
            sion.type = .undefined
        default:
            if Token.literals.hasMember(char) {
                let (type, value) = try parseValueLiteral()
                sion.type = type
                sion.value = value
            }
            else {
                error = .syntax(at: index, in: raw)
            }
        }
    }
    
    func parseDictionary() throws -> [String: SION] {
        var dict = [String: SION]()
        while let char = thisChar, char != Token.dictClose {
            let key = try parseKey()
            if !key.isEmpty {
                let value = try parseValue()
                if value.type != .undefined {
                    dict[key] = value
                }
            }
        }
        advance()
        return dict
    }
    
    func parseArray() throws -> [SION] {
        var array = [SION]()
        chompWhitespace()
        while thisChar != Token.arrayClose {
            chompWhitespace()
            let value = try parseValue()
            array.append(value)
        }
        advance()
        return array.filter { $0.type != .undefined }
    }
    
    func parseValue() throws -> SION {
        chompWhitespace()
        guard let char = thisChar, char != Token.delimVal else { throw Error.invalidValue(at: index, in: raw) }
        let (sion, newIndex) = try Parser.value(from: raw, at: index)
        self.index = newIndex
        chompValueDelim()
        return sion
    }
    
    func parseString(_ delim: Character) throws -> String {
        advance()
        let startIndex = index
        guard !atEnd else { throw Error.invalidValue(at: index, in: raw) }
        var valueEnd = false
        while !valueEnd, let nextChar = nextChar {
            if nextChar == delim && thisChar != Token.escape {
                valueEnd = true
            }
            advance()
        }
        let value = raw.substring(with: startIndex..<index)
        advance()
        chompValueDelim()
        return value
    }
    
    func parseValueLiteral() throws -> (SION.ValueType, Any?) {
        guard let char = thisChar else { throw Error.invalidKey(at: index, in: raw) }
        switch char {
        case "F" where chompIf(matching: "false"),
             "f" where chompIf(matching: "false"):
            return (.bool, false)
        case "T" where chompIf(matching: "true"),
             "t" where chompIf(matching: "true"):
            return (.bool, true)
        case "N" where chompIf(matching: "null"),
             "n" where chompIf(matching: "null"):
            return (.null, nil)
        default:
            if Token.numerics.hasMember(char) {
                let value = accumulateWhile { !Token.valueTerminators.hasMember($0) } .trimmingCharacters(in: Token.whitespaces)
                if let double = Double(value) {
                    return (.number, double)
                }
                else if let date = parseDate(value) {
                    return (.date, date)
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
    
    func parseDate(_ string: String) -> Date? {
        return DateFormatter.full.date(from: string) ?? DateFormatter.dateOnly.date(from: string)
    }

    static func formatDate(_ date: Date) -> String {
        return DateFormatter.full.string(from: date)
    }
    
    func parseKey() throws -> String {
        chompWhitespace()
        let endChar: Character
        let keyStartIndex: String.Index
        guard let char = thisChar else { throw Error.invalidKey(at: index, in: raw) }
        switch char {
        case Token.dictClose:
            return ""
        case Token.quoteSingle where !atEnd:
            keyStartIndex = raw.index(after: index)
            endChar = Token.quoteSingle
        case Token.quoteDouble where !atEnd:
            keyStartIndex = raw.index(after: index)
            endChar = Token.quoteDouble
        case Token.fwdSlash where nextChar == Token.fwdSlash:
            chompLineComment()
            return try parseKey()
        case Token.fwdSlash where nextChar == Token.star:
            chompBlockComment()
            return try parseKey()
        default:
            keyStartIndex = index
            endChar = Token.delimKey
        }
        
        var keyEnd = false
        while !keyEnd, let nextChar = nextChar {
            switch endChar {
            case Token.quoteSingle, Token.quoteDouble:
                if nextChar == endChar && thisChar != Token.escape {
                    keyEnd = true
                }
            case Token.delimKey:
                if nextChar == Token.delimKey || Token.whitespaces.hasMember(nextChar) {
                    keyEnd = true
                }
            default:
                break
            }
            advance()
        }
        let key = raw.substring(with: keyStartIndex..<index)
        advance()
        guard !key.isEmpty else { throw Error.invalidKey(at: keyStartIndex, in: raw) }
        
        chompWhitespace()
        if thisChar == Token.delimKey {
            advance()
            chompWhitespace()
        }

        return key
    }
    
}

private struct Token {
    static let dictOpen = Character("{")
    static let dictClose = Character("}")
    static let arrayOpen = Character("[")
    static let arrayClose = Character("]")
    static let quoteSingle = Character("'")
    static let quoteDouble = Character("\"")
    static let delimKey = Character(":")
    static let delimVal = Character(",")
    static let escape = Character("\\")
    static let fwdSlash = Character("/")
    static let star = Character("*")
    
    // token sets
    static let whitespaces = CharacterSet.whitespacesAndNewlines
    static let newlines = CharacterSet.newlines
    static let valueTerminators = CharacterSet(charactersIn: ",]}")
    static let numerics = CharacterSet(charactersIn: "0123456789-.")
    // characters that start a literal value:
    static let literals = CharacterSet(charactersIn: "0123456789-.tTfFnN")
}

extension CharacterSet {
    
    func hasMember(_ character: Character) -> Bool {
        var found = true
        for ch in String(character).utf16 {
            if !(self as NSCharacterSet).characterIsMember(ch) {
                found = false
            }
        }
        return found
    }

}


