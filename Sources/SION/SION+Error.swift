//
//  SION+Error.swift
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

    /// Represents an error during initialization
    public enum Error: Swift.Error {

        /// An unknown error
        case unknown

        /// Could not decode a string from the received data
        case stringFromData

        /// Could not parse valid SION from the received string. Includes a description of the syntax error and a portion of the raw string around the syntax error.
        case syntax(description: String, context: String)

        case stringifyFailed(description: String, path: String)

        init(parseError: ASTParser.Error) {
            let location: Int
            let descr: String
            let rawString: String
            let index: String.Index
            switch parseError {
            case let .nonDocumentRoot(raw):
                location = 0
                descr = "No Document Root Found"
                rawString = raw
                index = raw.startIndex
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

            self = .syntax(description: "\(descr) at character \(location)", context: String(rawString[leading..<trailing]))
        }
    }

}
