//
//  KeyedContainer.swift
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

public struct KeyedContainer: ASTContainer, Hashable {
    var keyValuePairs: [KeyValuePair]

    var isEmpty: Bool {
        keyValuePairs.isEmpty
    }

    var headComments: [Comment]
    var tailComments: [Comment]

    public let sionValueType = SION.ValueType.keyedContainer

    func value(for key: String) -> SION? {
        keyValuePairs.first { $0.key.name == key }?.value
    }

    mutating func setValue(_ value: SION, forKey key: String) {
        let keypair = KeyValuePair(key: Key(name: key), value: value)
        if let index = keyValuePairs.firstIndex(where: { $0.key.name == key }) {
            keyValuePairs.replaceSubrange(index...index, with: [keypair])
        } else {
            keyValuePairs.append(keypair)
        }
    }

    static func with(value: SION, forKey key: String) -> KeyedContainer {
        KeyedContainer(keyValuePairs: [
            KeyValuePair(key: Key(name: key),
                         value: value)
        ])
    }

    init(keyValuePairs: [KeyValuePair], headComments: [Comment] = [], tailComments: [Comment] = []) {
        self.keyValuePairs = keyValuePairs
        self.headComments = headComments
        self.tailComments = tailComments
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(keyValuePairs)
        hasher.combine(headComments)
        hasher.combine(tailComments)
    }

    public static func == (lhs: KeyedContainer, rhs: KeyedContainer) -> Bool {
        lhs.keyValuePairs == rhs.keyValuePairs
            && lhs.headComments == rhs.headComments
            && lhs.tailComments == rhs.tailComments
    }

    public var debugDescription: String {
        return """
        {
            \(keyValuePairs.map { $0.debugDescription }.joined(separator: ",\n    ")),
        }
        """
    }

}

struct KeyValuePair: ASTNode, Hashable, Comparable {

    var key: Key
    var value: SION

    static func == (lhs: KeyValuePair, rhs: KeyValuePair) -> Bool {
        lhs.key == rhs.key && lhs.value == rhs.value
    }

    static func < (lhs: KeyValuePair, rhs: KeyValuePair) -> Bool {
        lhs.key.name < rhs.key.name
    }

    var debugDescription: String {
        "\(key.debugDescription): \(value.debugDescription)"
    }

}

struct Key: ASTCommentableNode, Hashable {

    var name: String

    var headComments: [Comment] = []
    var tailComments: [Comment] = []

    var debugDescription: String {
        name
    }

}
