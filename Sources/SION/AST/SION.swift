//
//  SION.swift
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

@dynamicMemberLookup
public struct SION: ASTNode, Hashable {

    var value: ASTValue

    var headComments: [Comment] = []
    var tailComments: [Comment] = []

    var type: ValueType {
        value.sionValueType
    }

    public var debugDescription: String {
        value.debugDescription
    }

    public enum ValueType: Hashable {
        case string
        case number
        case date
        case bool
        case unkeyedContainer
        case keyedContainer
        case null
        case undefined
    }

    public func hash(into hasher: inout Hasher) {
        value.hash(into: &hasher)
        hasher.combine(headComments)
        hasher.combine(tailComments)
    }

    public static func == (lhs: SION, rhs: SION) -> Bool {
        lhs.value.isEqual(to: rhs.value)
            && lhs.headComments == rhs.headComments
            && lhs.tailComments == rhs.tailComments
    }
//
//    public static func == (lhs: SION, rhs: ASTValue) -> Bool {
//        lhs.value.isEqual(to: rhs)
//    }

}
