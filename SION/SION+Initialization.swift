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
        self.value = value
        self.type = .string
    }

    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.value = String(value)
        self.type = .string
    }

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.value = String(value)
        self.type = .string
    }

    public init(_ string: String) {
        self.value = string
        self.type = .string
    }

}


extension SION: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {

    public init(floatLiteral value: FloatLiteralType) {
        self.value = Double(value)
        self.type = .number
    }

    public init(integerLiteral value: IntegerLiteralType) {
        self.value = Double(value)
        self.type = .number
    }

    public init(_ number: Float) {
        self.value = Double(number)
        self.type = .number
    }

    public init(_ number: Int) {
        self.value = Double(number)
        self.type = .number
    }

    public init(_ number: Double) {
        self.value = number
        self.type = .number
    }

}

extension SION: ExpressibleByBooleanLiteral {

    public init(booleanLiteral value: BooleanLiteralType) {
        self.value = value
        self.type = .bool
    }

    public init(_ bool: Bool) {
        self.value = bool
        self.type = .bool
    }

}

extension SION {

    /**
     Initialize with a dictionary of [String: SION]. Order is not preserved.

     - parameters:
         - unorderedDictionary: A Swift Dictionary to initialize from
     */
    public init(unorderedDictionary: [String: SION]) {
        self.value = unorderedDictionary
        self.type = .dictionary
    }

    public init(_ keyValues: DictionaryLiteral<String, SION>) {
        self.type = .dictionary
        var orderedKeyValues = [(OrderedKey, SION)]()
        for i in 0..<keyValues.count {
            orderedKeyValues.append((OrderedKey(keyValues[i].0, i), keyValues[i].1))
        }
        self.value = [OrderedKey: SION](uniqueKeysWithValues: orderedKeyValues)
    }

    public init(_ array: [SION]) {
        self.value = array
        self.type = .array
    }

    public init(_ set: Set<SION>) {
        self.value = Array(set)
        self.type = .array
    }

}

extension SION {

    public init(_ date: Date) {
        self.value = date
        self.type = .date
    }

}

