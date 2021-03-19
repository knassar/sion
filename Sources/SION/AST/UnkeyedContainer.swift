//
//  UnkeyedContainer.swift
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

public struct UnkeyedContainer: ASTContainer, Hashable {

    var values: [SION]

    var isEmpty: Bool {
        values.isEmpty
    }

    var headComments: [Comment]
    var tailComments: [Comment]

    public let sionValueType = SION.ValueType.unkeyedContainer

    func value(at index: Int) -> SION? {
        guard index < values.count else { return nil }
        return values[index]
    }

    mutating func setValue(_ value: SION, at index: Int) {
        guard index >= 0 else { return }
        if index < values.count {
            values.replaceSubrange(index...index, with: [value])
        } else {
            for _ in values.count..<index {
                values.append(.null)
            }
            values.append(value)
        }
    }

    init(values: [SION], headComments: [Comment] = [], tailComments: [Comment] = []) {
        self.values = values
        self.headComments = headComments
        self.tailComments = tailComments
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(values)
        hasher.combine(headComments)
        hasher.combine(tailComments)
    }

    public static func == (lhs: UnkeyedContainer, rhs: UnkeyedContainer) -> Bool {
        lhs.values == rhs.values
            && lhs.headComments == rhs.headComments
            && lhs.tailComments == rhs.tailComments
    }

    public var debugDescription: String {
        return """
        [
            \(values.map { $0.debugDescription }.joined(separator: ",\n    ")),
        ]
        """
    }
}
