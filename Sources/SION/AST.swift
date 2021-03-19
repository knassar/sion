//
//  AST.swift
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

protocol ASTNode: CustomDebugStringConvertible {

}

protocol ASTCommentableNode: ASTNode {
    var commentsBefore: [AST.Comment] { get set }
    var commentsAfter: [AST.Comment] { get set }
}

protocol ASTWrappableNode: ASTCommentableNode {

    var value: AST.Value.ValueType { get }

}

protocol ASTContainer: ASTWrappableNode {

    var isEmpty: Bool { get }

}

enum AST {

    final class KeyedContainer: ASTContainer, Hashable {

        var keyValuePairs: [KeyValuePair]

        var isEmpty: Bool {
            keyValuePairs.isEmpty
        }

        var commentsBefore: [Comment]
        var commentsAfter: [Comment]

        var value: AST.Value.ValueType { .keyedContainer(self) }

        func value(for key: String) -> Value? {
            keyValuePairs.first { $0.key.name == key }?.value
        }

        func setValue(_ value: Value.ValueType, forKey key: String) {
            let keypair = KeyValuePair(key: Key(name: key, commentsBefore: [], commentsAfter: []),
                                       value: Value(value: value, commentsBefore: [], commentsAfter: []))
            if let index = keyValuePairs.firstIndex(where: { $0.key.name == key }) {
                keyValuePairs.replaceSubrange(index...index, with: [keypair])
            } else {
                keyValuePairs.append(keypair)
            }
        }

        static func with(value: Value.ValueType, forKey key: String) -> KeyedContainer {
            KeyedContainer(keyValuePairs: [
                KeyValuePair(key: Key(name: key, commentsBefore: [], commentsAfter: []),
                             value: Value(value: value, commentsBefore: [], commentsAfter: []))
            ])
        }

        init(keyValuePairs: [KeyValuePair], commentsBefore: [Comment] = [], commentsAfter: [Comment] = []) {
            self.keyValuePairs = keyValuePairs
            self.commentsBefore = commentsBefore
            self.commentsAfter = commentsAfter
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(keyValuePairs)
            hasher.combine(commentsBefore)
            hasher.combine(commentsAfter)
        }

        static func == (lhs: AST.KeyedContainer, rhs: AST.KeyedContainer) -> Bool {
            lhs.keyValuePairs == rhs.keyValuePairs
                && lhs.commentsBefore == rhs.commentsBefore
                && lhs.commentsAfter == rhs.commentsAfter
        }

        var debugDescription: String {
            return """
            {
                \(keyValuePairs.map { $0.debugDescription }.joined(separator: ",\n    ")),
            }
            """
        }

    }

    final class UnkeyedContainer: ASTContainer, Hashable {

        var values: [Value]

        var isEmpty: Bool {
            values.isEmpty
        }

        var commentsBefore: [Comment]
        var commentsAfter: [Comment]

        var value: AST.Value.ValueType { .unkeyedContainer(self) }

        func value(at index: Int) -> Value? {
            guard index < values.count else { return nil }
            return values[index]
        }

        func setValue(_ value: Value.ValueType, at index: Int) {
            guard index >= 0 else { return }
            let value = Value(value: value, commentsBefore: [], commentsAfter: [])
            if index < values.count {
                values.replaceSubrange(index...index, with: [value])
            } else {
                for _ in values.count..<index {
                    values.append(.null)
                }
                values.append(value)
            }
        }

        static func with(_ values: Value.ValueType...) -> UnkeyedContainer {
            UnkeyedContainer(values: values.map { Value(value: $0, commentsBefore: [], commentsAfter: []) })
        }

        init(values: [Value], commentsBefore: [Comment] = [], commentsAfter: [Comment] = []) {
            self.values = values
            self.commentsBefore = commentsBefore
            self.commentsAfter = commentsAfter
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(values)
            hasher.combine(commentsBefore)
            hasher.combine(commentsAfter)
        }

        static func == (lhs: AST.UnkeyedContainer, rhs: AST.UnkeyedContainer) -> Bool {
            lhs.values == rhs.values
                && lhs.commentsBefore == rhs.commentsBefore
                && lhs.commentsAfter == rhs.commentsAfter
        }

        var debugDescription: String {
            return """
            [
                \(values.map { $0.debugDescription }.joined(separator: ",\n    ")),
            ]
            """
        }
    }

    struct KeyValuePair: ASTNode, Hashable, Comparable {

        var key: Key
        var value: Value

        static func == (lhs: AST.KeyValuePair, rhs: AST.KeyValuePair) -> Bool {
            lhs.key == rhs.key && lhs.value == rhs.value
        }

        static func < (lhs: AST.KeyValuePair, rhs: AST.KeyValuePair) -> Bool {
            lhs.key.name < rhs.key.name
        }

        var debugDescription: String {
            "\(key.debugDescription): \(value.debugDescription)"
        }

    }

    struct Key: ASTCommentableNode, Hashable {

        var name: String

        var commentsBefore: [Comment]
        var commentsAfter: [Comment]

        var debugDescription: String {
            name
        }

    }

    struct Value: ASTWrappableNode, Hashable {

        var value: ValueType

        var commentsBefore: [Comment]
        var commentsAfter: [Comment]

        static let null = Value(value: .null, commentsBefore: [], commentsAfter: [])

        static let undefined = Value(value: .undefined, commentsBefore: [], commentsAfter: [])

        enum ValueType: Hashable, CustomDebugStringConvertible {
            case string(String)
            case number(Double)
            case date(Date)
            case bool(Bool)
            case unkeyedContainer(UnkeyedContainer)
            case keyedContainer(KeyedContainer)
            case null
            case undefined

            static func == (lhs: AST.Value.ValueType, rhs: AST.Value.ValueType) -> Bool {
                switch (lhs, rhs) {
                case let (.string(left), .string(right)):
                    return left == right
                case let (.number(left), .number(right)):
                    return left == right
                case let (.date(left), .date(right)):
                    return left == right
                case let (.bool(left), .bool(right)):
                    return left == right
                case let (.keyedContainer(left), .keyedContainer(right)):
                    return left == right
                case let (.unkeyedContainer(left), .unkeyedContainer(right)):
                    return left == right
                case (.null, .null):
                    return true
                case (.undefined, .undefined):
                    return false
                default:
                    return false
                }
            }

            var debugDescription: String {
                switch self {
                case let .string(string):
                    return string
                case let .number(double):
                    return "\(double)"
                case let .date(date):
                    return "\(date)"
                case let .bool(bool):
                    return bool ? "true" : "false"
                case .null:
                    return "NULL"
                case .undefined:
                    return "<undefined>"
                case let .unkeyedContainer(unkeyed):
                    return unkeyed.debugDescription
                case let .keyedContainer(keyed):
                    return keyed.debugDescription
                }
            }

        }

        var debugDescription: String {
            value.debugDescription
        }

    }

    enum Comment: ASTNode, Hashable {
        case block(String)
        case inline(String)

        var debugDescription: String {
            switch self {
            case let .block(text):
                return "<SION:BlockComment: '\(text)'>"
            case let .inline(text):
                return "<SION:InlineComment: '\(text)'>"
            }

        }

    }

}
