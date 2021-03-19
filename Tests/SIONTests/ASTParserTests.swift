//
//  ParserTests.swift
//  SIONTests
//
//  Created by Karim Nassar on 5/20/17.
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

import XCTest
@testable import SION

class ASTParserTests: XCTestCase {

    func testParse_empty() {
        do {
            _ = try ASTParser.parse("")
            XCTFail()
        } catch {
            // pass
        }

        do {
            _ = try ASTParser.parse("    \n \n  \t     \n")
            XCTFail()
        } catch {
            // pass
        }

        do {
            _ = try ASTParser.parse("   /* Foo Bar */   \n // FooBar")
            XCTFail()
        } catch {
            // pass
        }

    }
    
    func testParse_dictionary() {
        var dict: AST.KeyedContainer

        dict = try! ASTParser.parse("{}") as! AST.KeyedContainer
        XCTAssertTrue(dict.isEmpty)

        dict = try! ASTParser.parse(" {\n \n }") as! AST.KeyedContainer
        XCTAssertTrue(dict.isEmpty)

        dict = try! ASTParser.parse(" {\n 'foo': 'bar' \n }") as! AST.KeyedContainer
        XCTAssertFalse(dict.isEmpty)
        XCTAssertEqual(dict.keyValuePairs.count, 1)

        dict = try! ASTParser.parse(" {\n 'foo': 'bar',\n biff: \"bast\",\n date: 2017-04-01, /* Foo Bar */ \n dub: -23.56 }") as! AST.KeyedContainer
        XCTAssertFalse(dict.isEmpty)
        XCTAssertEqual(dict.value(for: "foo")?.value, .string("bar"))
        XCTAssertEqual(dict.value(for: "biff")?.value, .string("bast"))
        XCTAssertEqual(dict.value(for: "dub")?.value, .number(-23.56))
        XCTAssertEqual(dict.value(for: "date")?.value, .date(date(2017, 4, 1)!))
    }

    func testParse_array() {
        var array: AST.UnkeyedContainer

        array = try! ASTParser.parse("[]") as! AST.UnkeyedContainer
        XCTAssertTrue(array.isEmpty)

        array = try! ASTParser.parse(" [\n \n ]") as! AST.UnkeyedContainer
        XCTAssertTrue(array.isEmpty)

        array = try! ASTParser.parse(" [\n 'bar' \n ]") as! AST.UnkeyedContainer
        XCTAssertTrue(!array.isEmpty)
        XCTAssertEqual(array.value(at: 0)?.value, .string("bar"))

        array = try! ASTParser.parse(" [\n 'bar',\n \"bast\", \n -23.56, {\n bar: 'foo' \n} \n]") as! AST.UnkeyedContainer
        XCTAssertTrue(!array.isEmpty)
        XCTAssertEqual(array.value(at: 0)?.value, .string("bar"))
        XCTAssertEqual(array.value(at: 1)?.value, .string("bast"))
        XCTAssertEqual(array.value(at: 2)?.value, .number(-23.56))

        if case let .keyedContainer(dict) = array.value(at: 3)?.value {
            XCTAssertEqual(dict.value(for: "bar")?.value, .string("foo"))
        } else {
            XCTFail()
        }
    }

    func test_commentParse() {
        var dict = try! ASTParser.parse("""
        // before
        {
            // before 1st keypair
            key1 /* after key1 */: "value", // after 1st value

            // before 2nd keypair
            key2: "value", // after 2nd value
        }
        // after
        """) as! AST.KeyedContainer

        XCTAssertEqual(dict.commentsBefore, [.inline(" before")])
        XCTAssertEqual(dict.commentsAfter, [.inline(" after")])

        XCTAssertEqual(dict.keyValuePairs[0].key.commentsBefore, [.inline(" before 1st keypair")])
        XCTAssertEqual(dict.keyValuePairs[0].key.commentsAfter, [.block(" after key1 ")])
        XCTAssertEqual(dict.keyValuePairs[0].value.commentsAfter, [.inline(" after 1st value")])

        XCTAssertEqual(dict.keyValuePairs[1].key.commentsBefore, [.inline(" before 2nd keypair")])
        XCTAssertEqual(dict.keyValuePairs[1].value.commentsAfter, [.inline(" after 2nd value")])

        dict = try! ASTParser.parse("""
        /* before */
        {
            /* before 1st keypair */
            key1: "value", /* after 1st value */

            /* before 2nd keypair */
            /* before key2 too */ key2: "value", /* after 2nd value
            also after */
        }
        /* after */
        """) as! AST.KeyedContainer

        XCTAssertEqual(dict.commentsBefore, [.block(" before ")])
        XCTAssertEqual(dict.commentsAfter, [.block(" after ")])

        XCTAssertEqual(dict.keyValuePairs[0].key.commentsBefore, [.block(" before 1st keypair ")])
        XCTAssertEqual(dict.keyValuePairs[0].value.commentsAfter, [.block(" after 1st value ")])

        XCTAssertEqual(dict.keyValuePairs[1].key.commentsBefore, [.block(" before 2nd keypair "), .block(" before key2 too ")])
        XCTAssertEqual(dict.keyValuePairs[1].value.commentsAfter, [.block(" after 2nd value\n    also after ")])

    }

    func test_overallParse() {
        guard
            let filePath = Bundle.module.path(forResource: "test", ofType: "sion"),
            let string = try? String(contentsOfFile: filePath)
            else { return XCTFail() }

        let test = try! ASTParser.parse(string) as! AST.KeyedContainer
        XCTAssertFalse(test.isEmpty)

        XCTAssertEqual(test.commentsBefore.first, .block("""
         \

            SION is Simplified, Improved Object Notation
            This is a SION sampler for testing the parser

        """))

        XCTAssertEqual(test.keyValuePairs.first?.key.commentsBefore, [
            .inline(" Valid JSON is valid SION"),
            .inline(" But we also get comments!")
        ])

        guard case let .keyedContainer(json) = test.value(for: "json")?.value else {
            XCTFail("did not correctly parse")
            return
        }

        XCTAssertEqual(json.value(for: "string")?.value, .string("foo"))
        XCTAssertEqual(json.value(for: "number")?.value, .number(1234.9012))
        XCTAssertEqual(json.value(for: "boolean")?.value, .bool(true))
        XCTAssertTrue(json.value(for: "boolean")!.commentsAfter.isEmpty)
        XCTAssertEqual(json.value(for: "nothin")?.value, .null)
        XCTAssertEqual(json.keyValuePairs[3].key.commentsBefore.first, .block(" \n            and \n            block \n            comments \n        "))

        guard case let .unkeyedContainer(arr) = json.value(for: "array")?.value else {
            XCTFail("did not correctly parse")
            return
        }

        XCTAssertEqual(arr.values.count, 3)
        XCTAssertEqual(arr.value(at: 1)?.value, .string("b"))
        XCTAssertEqual(arr.value(at: 1)?.commentsBefore, [.inline(" of course, whitespace is generally ignored")])

        guard case let .keyedContainer(dict) = json.value(for: "dict")?.value else {
            XCTFail("did not correctly parse")
            return
        }

        let expectedArr = AST.Value.ValueType.unkeyedContainer(AST.UnkeyedContainer(values: [
            AST.Value(value: .number(1), commentsBefore: [], commentsAfter: []),
            AST.Value(value: .number(2), commentsBefore: [], commentsAfter: []),
            AST.Value(value: .string("c"), commentsBefore: [], commentsAfter: []),
        ], commentsBefore: [], commentsAfter: []))

        XCTAssertEqual(dict.value(for: "arr")?.value, expectedArr)

        XCTAssertEqual(dict.value(for: "nil")?.value, .null)
        XCTAssertEqual(dict.value(for: "boo")?.value, .bool(true))

        guard case let .keyedContainer(keys) = test.value(for: "keys")?.value else {
            XCTFail("did not correctly parse")
            return
        }

        XCTAssertEqual(keys.keyValuePairs.count, 2, "trailing commas are safe")

        var keyPair = keys.keyValuePairs[0]
        XCTAssertEqual(keyPair.value.value, .string("yay!"), "we can skip quoting dictionary keys if there is no whitespace in them")
        XCTAssertEqual(keyPair.key.commentsBefore, [
            .inline(" we can skip quoting dictionary keys"),
            .inline(" if there is no whitespace in them"),
        ])

        keyPair = keys.keyValuePairs[1]
        XCTAssertEqual(keyPair.value.value, .string("cool"), "plus we can use single quotes to avoid escaping doubles")
        XCTAssertEqual(keyPair.key.commentsBefore, [
            .inline(" plus we can use single quotes to avoid escaping doubles"),
            ])
        XCTAssertEqual(keyPair.value.commentsAfter, [
            .inline(" <-- trailing commas are safe"),
            ])

        guard case let .unkeyedContainer(values) = test.value(for: "values")?.value else {
            XCTFail("did not correctly parse")
            return
        }

        XCTAssertEqual(values.values[0].value, .string("pile o' strings"))
        XCTAssertEqual(values.values[1].value, .string("and \"strings\""))
        XCTAssertEqual(values.values[1].commentsAfter, [.inline(" double or single quoting")])

        XCTAssertEqual(values.values[2].value, .number(-1234.2342))
        XCTAssertEqual(values.values[2].commentsAfter, [.inline(" numbers")])

        XCTAssertEqual(values.values[3].value, .bool(true))
        XCTAssertEqual(values.values[4].value, .bool(false))
        XCTAssertEqual(values.values[4].commentsAfter, [.inline(" bools")])

        XCTAssertEqual(values.values[5].value, .null)
        XCTAssertEqual(values.values[5].commentsAfter, [.inline(" null")])

        XCTAssertEqual(values.values[6].value, .date(date(2013, 6, 13)!))
        XCTAssertEqual(values.values[6].commentsAfter, [.inline(" date literals!")])

        XCTAssertEqual(values.values[7].value, .date(date(2011, 1, 10, 8, 1, 0)!))
        XCTAssertEqual(values.values[7].commentsAfter, [.inline(" date time literals!")])

        let expectedDict = AST.Value.ValueType.keyedContainer(AST.KeyedContainer(keyValuePairs: [
            AST.KeyValuePair(key: AST.Key(name: "nesting", commentsBefore: [], commentsAfter: []),
                             value: AST.Value(value: .string("dictionaries"), commentsBefore: [], commentsAfter: [.block(" of course ")]))
        ], commentsBefore: [], commentsAfter: []))

        XCTAssertEqual(values.values[8].value, expectedDict, "nested dictionary")

        let expectedArray = AST.Value.ValueType.unkeyedContainer(AST.UnkeyedContainer(values: [
            AST.Value(value: .string("nesting"), commentsBefore: [], commentsAfter: []),
            AST.Value(value: .string("arrays"), commentsBefore: [], commentsAfter: []),
            AST.Value(value: .string("natch"), commentsBefore: [], commentsAfter: []),
        ], commentsBefore: [], commentsAfter: []))

        XCTAssertEqual(values.values[9].value, expectedArray, "nested array")
//
    }
    
}
