//
//  SION+Initialization.swift
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

    public init() {
        self.value = Undefined()
    }

    /// an undefined SION value
    public static let undefined = SION(value: Undefined())

    /// a null SION value
    public static let null = SION(value: Null())

    init(value: ASTValue) {
        self.value = value
    }

    /**
     Initialze from a string representation as from a file

     - throws:
     `SION.Error` when parse fails

     - parameters:
        - raw: The string contents of the file or string literal

     */
    public init(parsing rawString: String) throws {
        do {
            self.value = try ASTParser.parse(rawString)
        }
        catch let parseError as ASTParser.Error {
            throw Error.init(parseError: parseError)
        }
    }

    /**
     Initialze from `Data` representation as from a file

     - throws:
     `SION.Error` when decoding or parse fails

     - parameters:
         - data: The data contents of the file
         - encoding: Expected `String.Encoding` to use to decode the `Data`
     */
    public init(data: Data, encoding: String.Encoding = .utf8) throws {
        guard let str = String(data: data, encoding: encoding) else { throw Error.stringFromData }
        try self.init(parsing: str)
    }

}

extension SION: ExpressibleByStringLiteral, ExpressibleByExtendedGraphemeClusterLiteral, ExpressibleByUnicodeScalarLiteral {

    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String

    public init(stringLiteral value: StringLiteralType) {
        self.value = value
    }

    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.value = value
    }

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.value = value
    }

    public init(_ string: String) {
        self.value = string
    }

}


extension SION: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {

    public init(floatLiteral value: FloatLiteralType) {
        self.value = Numeric.double(value)
    }

    public init(integerLiteral value: IntegerLiteralType) {
        self.value = Numeric.int(value)
    }

    public init(_ number: Float) {
        self.value = Numeric.float(number)
    }

    public init(_ number: Int) {
        self.value = Numeric.int(number)
    }

    public init(_ number: Double) {
        self.value = Numeric.double(number)
    }

    public init(_ number: CGFloat) {
        self.value = Numeric.cgFloat(number)
    }

}

extension SION: ExpressibleByBooleanLiteral {

    public init(booleanLiteral value: BooleanLiteralType) {
        self.value = value
    }

    public init(_ bool: Bool) {
        self.value = bool
    }

}

extension SION {

    /**
     Initialize with a dictionary of [String: SION]. Order is not preserved.

     - parameters:
         - unorderedDictionary: A Swift Dictionary to initialize from
     */
    public init(unorderedDictionary: [String: ASTValue]) {
        self.value = KeyedContainer(keyValuePairs: unorderedDictionary.map {
            KeyValuePair(key: Key(name: $0.key), value: SION(value: $0.value))
        })
    }

    public init(_ keyValues: KeyValuePairs<String, ASTValue>) {
        self.value = KeyedContainer(keyValuePairs: keyValues.map {
            KeyValuePair(key: Key(name: $0.key), value: SION(value: $0.value))
        })
    }

    public init(unorderedDictionary: [String: SION]) {
        self.value = KeyedContainer(keyValuePairs: unorderedDictionary.map {
            KeyValuePair(key: Key(name: $0.key), value: $0.value)
        })
    }

    public init(_ keyValues: KeyValuePairs<String, SION>) {
        self.value = KeyedContainer(keyValuePairs: keyValues.map {
            KeyValuePair(key: Key(name: $0.key), value: $0.value)
        })
    }

    public init(_ array: [ASTValue]) {
        self.value = UnkeyedContainer(values: array.map {
            SION(value: $0)
        })
    }

    public init(_ array: [SION]) {
        self.value = UnkeyedContainer(values: array)
    }

//
//    public init(_ set: Set<ASTValue>) {
//        self.init(Array(set))
//    }
//
}

extension SION {

    public init(_ date: Date) {
        self.value = date
    }

}

