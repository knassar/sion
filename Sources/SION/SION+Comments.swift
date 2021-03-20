//
//  SION+Comments.swift
//  SION
//
//  Created by Karim Nassar on 1/19/21.
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

    public var comments: Comments? {
        guard let value = self.value as? ASTCommentableNode else {
             return nil
        }
        return Comments(head: value.headComments.map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) },
                        tail: value.tailComments.map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) })
    }

    public struct Comments {
        public var head: [String]
        public var tail: [String]
    }

    public mutating func addHeadComment(_ comment: String, preferBlock: Bool = false) {
        headComments.append(.with(comment, preferBlock: preferBlock))
    }

    public mutating func addTailComment(_ comment: String, preferBlock: Bool = false) {
        tailComments.append(.with(comment, preferBlock: preferBlock))
    }

    public mutating func stripComments() {
        stripHeadComments()
        stripTailComments()
    }

    public mutating func stripHeadComments() {
        headComments.removeAll()
    }

    public mutating func stripTailComments() {
        tailComments.removeAll()
    }

}

extension KeyedContainer {

    public mutating func addHeadComment(_ comment: String, preferBlock: Bool = false, forKey key: String) {
        self.addComment(.with(comment, preferBlock: preferBlock), in: \.headComments, forKey: key)
    }

    public mutating func addTailComment(_ comment: String, preferBlock: Bool = false, forKey key: String) {
        self.addComment(.with(comment, preferBlock: preferBlock), in: \.tailComments, forKey: key)
    }

    private mutating func addComment(_ comment: Comment, in keyPath: WritableKeyPath<Key, [Comment]>, forKey key: String) {
        if let index = keyValuePairs.firstIndex(where: { $0.key.name == key }) {
            var keyValuePair = keyValuePairs[index]
            keyValuePair.key[keyPath: keyPath].append(comment)
            keyValuePairs.replaceSubrange(index...index, with: [keyValuePair])
        } else {
            var key = Key(name: "key")
            key[keyPath: keyPath] = [comment]
            keyValuePairs.append(KeyValuePair(key: key, value: .undefined))
        }
    }

    public mutating func stripComments(forKey key: String) {
        stripHeadComments(forKey: key)
        stripTailComments(forKey: key)
    }

    public mutating func stripHeadComments(forKey key: String) {
        stripComments(in: \.headComments, forKey: key)
    }

    public mutating func stripTailComments(forKey key: String) {
        stripComments(in: \.tailComments, forKey: key)
    }

    private mutating func stripComments(in keyPath: WritableKeyPath<Key, [Comment]>, forKey key: String) {
        if let index = keyValuePairs.firstIndex(where: { $0.key.name == key }) {
            var keyValuePair = keyValuePairs[index]
            keyValuePair.key[keyPath: keyPath].removeAll()
            keyValuePairs.replaceSubrange(index...index, with: [keyValuePair])
        }
    }

}
