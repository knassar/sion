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

extension SION: ExpressibleByStringLiteral, ExpressibleByExtendedGraphemeClusterLiteral, ExpressibleByUnicodeScalarLiteral {

    public typealias StringLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String

    public init(stringLiteral value: StringLiteralType) {
        self.node = AST.Value(value: .string(value), commentsBefore: [], commentsAfter: [])
    }

    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.node = AST.Value(value: .string(value), commentsBefore: [], commentsAfter: [])
    }

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.node = AST.Value(value: .string(value), commentsBefore: [], commentsAfter: [])
    }

    public init(_ string: String) {
        self.node = AST.Value(value: .string(string), commentsBefore: [], commentsAfter: [])
    }

}


extension SION: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {

    public init(floatLiteral value: FloatLiteralType) {
        self.node = AST.Value(value: .number(value), commentsBefore: [], commentsAfter: [])
    }

    public init(integerLiteral value: IntegerLiteralType) {
        self.node = AST.Value(value: .number(Double(value)), commentsBefore: [], commentsAfter: [])
    }

    public init(_ number: Float) {
        self.node = AST.Value(value: .number(Double(number)), commentsBefore: [], commentsAfter: [])
    }

    public init(_ number: Int) {
        self.node = AST.Value(value: .number(Double(number)), commentsBefore: [], commentsAfter: [])
    }

    public init(_ number: Double) {
        self.node = AST.Value(value: .number(number), commentsBefore: [], commentsAfter: [])
    }

}

extension SION: ExpressibleByBooleanLiteral {

    public init(booleanLiteral value: BooleanLiteralType) {
        self.node = AST.Value(value: .bool(value), commentsBefore: [], commentsAfter: [])
    }

    public init(_ bool: Bool) {
        self.node = AST.Value(value: .bool(bool), commentsBefore: [], commentsAfter: [])
    }

}

extension SION {

    /**
     Initialize with a dictionary of [String: SION]. Order is not preserved.

     - parameters:
         - unorderedDictionary: A Swift Dictionary to initialize from
     */
    public init(unorderedDictionary: [String: SION]) {
        self.node = AST.KeyedContainer(keyValuePairs: unorderedDictionary.map {
            AST.KeyValuePair(key: AST.Key(name: $0.key, commentsBefore: [], commentsAfter: []),
                             value: AST.Value(value: $0.value.node.value, commentsBefore: [], commentsAfter: []))
        }, commentsBefore: [], commentsAfter: [])
    }

    public init(_ keyValues: KeyValuePairs<String, SION>) {
        self.node = AST.KeyedContainer(keyValuePairs: keyValues.map {
            AST.KeyValuePair(key: AST.Key(name: $0.key, commentsBefore: [], commentsAfter: []),
                             value: AST.Value(value: $0.value.node.value, commentsBefore: [], commentsAfter: []))
        }, commentsBefore: [], commentsAfter: [])
    }

    public init(_ array: [SION]) {
        self.node = AST.UnkeyedContainer(values: array.map {
            AST.Value(value: $0.node.value, commentsBefore: [], commentsAfter: [])
        }, commentsBefore: [], commentsAfter: [])
    }

    public init(_ set: Set<SION>) {
        self.init(Array(set))
    }

}

extension SION {

    public init(_ date: Date) {
        self.node = AST.Value(value: .date(date), commentsBefore: [], commentsAfter: [])
    }

}

