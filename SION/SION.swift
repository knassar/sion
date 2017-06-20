//
//  SION.swift
//  SION
//
//  Created by Karim Nassar on 5/20/17.
//  Copyright © 2017 HungryMelonStudios LLC. All rights reserved.
//

import Foundation

public protocol SIONKey {}
extension String: SIONKey {}
extension Int: SIONKey {}

public struct SION {
    
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
            }
            else {
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
                if let a = value as? Array<SION>, index < a.count {
                    return a[index]
                }
                else {
                    return SION.undefined
                }
            case .dictionary where key is String:
                let key = key as! String
                if let d = value as? Dictionary<String, SION> {
                    return d[key] ?? SION.undefined
                }
                else {
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
                if var a = value as? Array<SION> {
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
                if var d = value as? Dictionary<String, SION> {
                    d[key] = newValue
                    value = d
                }
            default:
                return
            }
        }
    }
    
    var value: Any? = nil
    var type = ValueType.undefined
    
    public enum Error: Swift.Error {
        case unknown
        case stringFromData
        case syntax(description: String, context: String)
        
        internal init(parseError: Parser.Error) {
            let location: Int
            let descr: String
            let rawString: String
            let index: String.Index
            switch parseError {
            case let .syntax(idx, raw):
                location = raw.distance(from: raw.startIndex, to: idx)
                descr = "Syntax Error"
                rawString = raw
                index = idx
            case let .invalidKey(idx, raw):
                location = raw.distance(from: raw.startIndex, to: idx)
                descr = "Invalid Key"
                rawString = raw
                index = idx
            case let .invalidValue(idx, raw):
                location = raw.distance(from: raw.startIndex, to: idx)
                descr = "Invalid Value"
                rawString = raw
                index = idx
            case .none:
                self = .unknown
                return
            }
            
            var leading = index
            var trailing = index
            for _ in 0..<8 {
                if leading != rawString.startIndex {
                    leading = rawString.index(before: leading)
                }
                if trailing != rawString.endIndex {
                    trailing = rawString.index(after: trailing)
                }
            }
            
            self = .syntax(description: "\(descr) at character \(location)", context: rawString.substring(with: leading..<trailing))
        }
    }
    
    public private(set) var rawString: String?
    
    init() {}
    
    enum ValueType {
        case array
        case bool
        case date
        case dictionary
        case null
        case number
        case string
        case undefined
    }

    public static let undefined = SION(type: .undefined)
    public static let null = SION(type: .null)
    
    init(type: SION.ValueType, value: Any? = nil) {
        self.value = value
        self.type = type
    }
    
    public init(raw: String) throws {
        self.rawString = raw
        do {
            let parsed = try Parser.parse(raw)
            self.type = parsed.type
            self.value = parsed.value
        }
        catch (let e) {
            guard let parseError = e as? Parser.Error else { throw e }
            throw Error.init(parseError: parseError)
        }
    }

    public init(data: Data, encoding: String.Encoding = .utf8) throws {
        guard let str = String(data: data, encoding: encoding) else { throw Error.stringFromData }
        try self.init(raw: str)
    }
}

// MARK: - Data Accessors

extension SION {
    
    public var isEmpty: Bool {
        switch type {
        case .undefined, .null,
             .array where (value as? Array ?? []).isEmpty,
             .dictionary where (value as? Dictionary ?? [:]).isEmpty,
             .string where (value as? String ?? "").isEmpty:
            return true
        default:
            return false
        }
    }
    
    public var isNull: Bool {
        return type == .null
    }

    public var isUndefined: Bool {
        return type == .undefined
    }

    public var string: String? {
        switch type {
        case .string where value is String:
            return value as? String
        default:
            return nil
        }
    }
    public var stringValue: String {
        return string ?? ""
    }
    
    public var bool: Bool? {
        switch type {
        case .bool where value is Bool:
            return value as? Bool
        default:
            return nil
        }
    }
    public var boolValue: Bool {
        return bool ?? false
    }
    
    public var number: Double? {
        switch type {
        case .number where value is Double:
            return value as? Double
        default:
            return nil
        }
    }
    public var numberValue: Double {
        return number ?? 0
    }
    
    public var int: Int? {
        guard let double = number else { return nil }
        return Int(double)
    }
    public var intValue: Int {
        return int ?? 0
    }

    public var float: Float? {
        guard let double = number else { return nil }
        return Float(double)
    }
    public var floatValue: Float {
        return float ?? 0
    }

    public var date: Date? {
        switch type {
        case .date where value is Date:
            return value as? Date
        default:
            return nil
        }
    }
    public var dateValue: Date {
        return date ?? Date.distantPast
    }
    
    public var array: [SION]? {
        switch type {
        case .array where value is [SION]:
            return value as? [SION]
        default:
            return nil
        }
    }
    public var arrayValue: [SION] {
        return array ?? []
    }
    
    public var dictionary: [String: SION]? {
        switch type {
        case .dictionary where value is [String:SION]:
            return value as? [String:SION]
        default:
            return nil
        }
    }
    public var dictionaryValue: [String:SION] {
        return dictionary ?? [:]
    }

}


extension SION: ExpressibleByStringLiteral, ExpressibleByExtendedGraphemeClusterLiteral, ExpressibleByUnicodeScalarLiteral {
    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self.value = value
        type = .string
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.value = String(value)
        type = .string
    }
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.value = String(value)
        type = .string
    }
    
    public init(_ string: String) {
        self.value = string
        type = .string
    }
    
}


extension SION: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self.value = Double(value)
        type = .number
    }
    
    public init(integerLiteral value: IntegerLiteralType) {
        self.value = Double(value)
        type = .number
    }
    
    public init(_ number: Float) {
        self.value = Double(number)
        type = .number
    }
    
    public init(_ number: Int) {
        self.value = Double(number)
        type = .number
    }
    
    public init(_ number: Double) {
        self.value = number
        type = .number
    }
}

extension SION: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self.value = value
        type = .bool
    }
    
    public init(_ bool: Bool) {
        self.value = bool
        type = .bool
    }
}

extension SION {
    
    public init(_ dict: [String: SION]) {
        self.value = dict
        type = .dictionary
    }
    
    public init(_ array: [SION]) {
        self.value = array
        type = .array
    }
    
    public init(_ set: Set<SION>) {
        self.value = Array(set)
        type = .array
    }
    
}

extension SION {
    public init(_ date: Date) {
        self.value = date
        self.type = .date
    }
}

extension SION: Hashable {
    
    public var hashValue: Int {
        switch type {
        case .string:
            return (value as? String)?.hashValue ?? 0
        case .bool:
            return (value as? Bool)?.hashValue ?? 0
        case .number:
            return (value as? Double)?.hashValue ?? 0
        case .date:
            return (value as? Date)?.hashValue ?? 0
        case .array:
            let hash = arrayValue.map { $0.hashValue } .reduce(0) { $0 ^ $1 }
            return "array:\(hash)".hashValue
        case .dictionary:
            let v = dictionaryValue
            let hash = v.keys.map { "\($0):\(v[$0]?.hashValue ?? 0)".hashValue } .reduce(0) { $0 ^ $1 }
            return "dict:\(hash)".hashValue
        case .undefined, .null:
            return 0
        }
    }
    
    public static func ==(l: SION, r: SION) -> Bool {
        switch (l.type, r.type) {
        case (.string, .string):
            return l.string == r.string
        case (.bool, .bool):
            return l.bool == r.bool
        case (.number, .number):
            return l.number == r.number
        case (.date, .date):
            return l.date == r.date
        case (.array, .array):
            guard
                let lArr = l.array,
                let rArr = r.array,
                lArr.count == rArr.count
                else { return false }
            for (a, b) in zip(lArr, rArr) {
                guard a == b else { return false }
            }
            return true
        case (.dictionary, .dictionary):
            guard
                let lDict = l.dictionary,
                let rDict = r.dictionary,
                lDict.keys.count == rDict.keys.count
                else { return false }
            
            for key in lDict.keys {
                guard lDict[key] == lDict[key] else { return false }
            }
            return true
        case (.null, .null):
            return true
        case (.undefined, .undefined):
            return false
        default:
            return false
        }
    }
}

