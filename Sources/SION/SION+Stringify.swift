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

    /// strip all comments when strigifying
    public static let stripComments = StringifyOptions(rawValue: 1 << 4)

    var includeComments: Bool {
        return !self.contains(.json) && !self.contains(.stripComments) && self.contains(.pretty)
    }

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
        if options.contains(.json) {
            return JSONPrinter(options: options).print(node)
        } else {
            return SIONPrinter(options: options).print(node)
        }
    }

}



