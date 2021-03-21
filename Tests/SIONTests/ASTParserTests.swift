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
        var dict: KeyedContainer

        dict = try! ASTParser.parse("{}") as! KeyedContainer
        XCTAssertTrue(dict.isEmpty)

        dict = try! ASTParser.parse(" {\n \n }") as! KeyedContainer
        XCTAssertTrue(dict.isEmpty)

        dict = try! ASTParser.parse(" {\n 'foo': 'bar' \n }") as! KeyedContainer
        XCTAssertFalse(dict.isEmpty)
        XCTAssertEqual(dict.keyValuePairs.count, 1)

        dict = try! ASTParser.parse(" {\n 'foo': 'bar',\n biff: \"bast\",\n date: 2017-04-01, /* Foo Bar */ \n dub: -23.56 }") as! KeyedContainer
        XCTAssertFalse(dict.isEmpty)
        XCTAssertEqual(dict.value(for: "foo")?.string, "bar")
        XCTAssertEqual(dict.value(for: "biff")?.string, "bast")
        XCTAssertEqual(dict.value(for: "dub")?.double, -23.56)
        XCTAssertEqual(dict.value(for: "date")?.date, date(2017, 4, 1)!)
    }

    func testParse_array() {
        var array: UnkeyedContainer

        array = try! ASTParser.parse("[]") as! UnkeyedContainer
        XCTAssertTrue(array.isEmpty)

        array = try! ASTParser.parse(" [\n \n ]") as! UnkeyedContainer
        XCTAssertTrue(array.isEmpty)

        array = try! ASTParser.parse(" [\n 'bar' \n ]") as! UnkeyedContainer
        XCTAssertTrue(!array.isEmpty)
        XCTAssertEqual(array.value(at: 0)?.value as? String, "bar")

        array = try! ASTParser.parse(" [\n 'bar',\n \"bast\", \n -23.56, {\n bar: 'foo' \n} \n]") as! UnkeyedContainer
        XCTAssertTrue(!array.isEmpty)
        XCTAssertEqual(array.value(at: 0)?.string, "bar")
        XCTAssertEqual(array.value(at: 1)?.string, "bast")
        XCTAssertEqual(array.value(at: 2)?.double, -23.56)

        XCTAssertTrue((array.value(at: 3)?.value as? KeyedContainer)?.value(for: "bar") == "foo")
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
        """) as! KeyedContainer

        XCTAssertEqual(dict.headComments, [.inline(" before")])
        XCTAssertEqual(dict.tailComments, [.inline(" after")])

        XCTAssertEqual(dict.keyValuePairs[0].key.headComments, [.inline(" before 1st keypair")])
        XCTAssertEqual(dict.keyValuePairs[0].key.tailComments, [.block(" after key1 ")])
        XCTAssertEqual(dict.keyValuePairs[0].value.tailComments, [.inline(" after 1st value")])

        XCTAssertEqual(dict.keyValuePairs[1].key.headComments, [.inline(" before 2nd keypair")])
        XCTAssertEqual(dict.keyValuePairs[1].value.tailComments, [.inline(" after 2nd value")])

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
        """) as! KeyedContainer

        XCTAssertEqual(dict.headComments, [.block(" before ")])
        XCTAssertEqual(dict.tailComments, [.block(" after ")])

        XCTAssertEqual(dict.keyValuePairs[0].key.headComments, [.block(" before 1st keypair ")])
        XCTAssertEqual(dict.keyValuePairs[0].value.tailComments, [.block(" after 1st value ")])

        XCTAssertEqual(dict.keyValuePairs[1].key.headComments, [.block(" before 2nd keypair "), .block(" before key2 too ")])
        XCTAssertEqual(dict.keyValuePairs[1].value.tailComments, [.block(" after 2nd value\n    also after ")])

    }

    func test_unquotedLiteral() {
        let dict = try! ASTParser.parse("""
        {
            key: unquotedLiteral,
        }
        """) as! KeyedContainer

        XCTAssertEqual(dict.value(for: "key")?.stringValue, "unquotedLiteral")
    }

    func test_overallParse() {
        guard
            let filePath = Bundle.module.path(forResource: "test", ofType: "sion"),
            let string = try? String(contentsOfFile: filePath)
            else { return XCTFail() }

        let test = try! ASTParser.parse(string) as! KeyedContainer
        XCTAssertFalse(test.isEmpty)

        XCTAssertEqual(test.headComments.first, .block("""
         \

            SION is Simplified, Improved Object Notation
            This is a SION sampler for testing the parser

        """))

        XCTAssertEqual(test.keyValuePairs.first?.key.headComments, [
            .inline(" Valid JSON is valid SION"),
            .inline(" But we also get comments!")
        ])

        guard let json = test.value(for: "json")?.value as? KeyedContainer else {
            XCTFail("did not correctly parse")
            return
        }

        XCTAssertEqual(json.value(for: "string")?.string, "foo")
        XCTAssertEqual(json.value(for: "number")?.double, 1234.9012)
        XCTAssertEqual(json.value(for: "boolean")?.bool, true)
        XCTAssertTrue(json.value(for: "boolean")!.tailComments.isEmpty)
        XCTAssertTrue(json.value(for: "nothin")!.isNull)
        XCTAssertEqual(json.keyValuePairs[3].key.headComments.first, .block(" \n            and \n            block \n            comments \n        "))

        guard let arr = json.value(for: "array")?.value as? UnkeyedContainer else {
            XCTFail("did not correctly parse")
            return
        }

        XCTAssertEqual(arr.values.count, 3)
        XCTAssertEqual(arr.value(at: 1)?.string, "b")
        XCTAssertEqual(arr.value(at: 1)?.headComments, [.inline(" of course, whitespace is generally ignored")])

        guard let dict = json.value(for: "dict")?.value as? KeyedContainer else {
            XCTFail("did not correctly parse")
            return
        }

        let expectedArr = UnkeyedContainer(values: [
            1,
            2,
            "c",
        ], headComments: [], tailComments: [])

        XCTAssertEqual(dict.value(for: "arr")?.value as? UnkeyedContainer, expectedArr)

        XCTAssertTrue(dict.value(for: "nil")!.isNull)
        XCTAssertTrue(dict.value(for: "boo") == true)

        guard let keys = test.value(for: "keys")?.value as? KeyedContainer else {
            XCTFail("did not correctly parse")
            return
        }

        XCTAssertEqual(keys.keyValuePairs.count, 2, "trailing commas are safe")

        var keyPair = keys.keyValuePairs[0]
        XCTAssertEqual(keyPair.value.value as? String, "yay!", "we can skip quoting dictionary keys if there is no whitespace in them")
        XCTAssertEqual(keyPair.key.headComments, [
            .inline(" we can skip quoting dictionary keys"),
            .inline(" if there is no whitespace in them"),
        ])

        keyPair = keys.keyValuePairs[1]
        XCTAssertEqual(keyPair.value.value as? String, "cool", "plus we can use single quotes to avoid escaping doubles")
        XCTAssertEqual(keyPair.key.headComments, [
            .inline(" plus we can use single quotes to avoid escaping doubles"),
            ])
        XCTAssertEqual(keyPair.value.tailComments, [
            .inline(" <-- trailing commas are safe"),
            ])

        guard let values = test.value(for: "values")?.value as? UnkeyedContainer else {
            XCTFail("did not correctly parse")
            return
        }

        XCTAssertEqual(values.values[0].string, "pile o' strings")
        XCTAssertEqual(values.values[1].string, "and \"strings\"")
        XCTAssertEqual(values.values[1].tailComments, [.inline(" double or single quoting")])

        XCTAssertEqual(values.values[2].double, -1234.2342)
        XCTAssertEqual(values.values[2].tailComments, [.inline(" numbers")])

        XCTAssertEqual(values.values[3].bool, true)
        XCTAssertEqual(values.values[4].bool, false)
        XCTAssertEqual(values.values[4].tailComments, [.inline(" bools")])

        XCTAssertTrue(values.values[5].isNull)
        XCTAssertEqual(values.values[5].tailComments, [.inline(" null")])

        XCTAssertEqual(values.values[6].date, date(2013, 6, 13)!)
        XCTAssertEqual(values.values[6].tailComments, [.inline(" date literals!")])

        XCTAssertEqual(values.values[7].date, date(2011, 1, 10, 8, 1, 0)!)
        XCTAssertEqual(values.values[7].tailComments, [.inline(" date time literals!")])

        let expectedDict = KeyedContainer(keyValuePairs: [
            KeyValuePair(key: Key(name: "nesting"),
                             value: SION(value: "dictionaries", tailComments: [.block(" of course ")]))
        ])

        XCTAssertEqual(values.values[8].value as? KeyedContainer, expectedDict, "nested dictionary")

        let expectedArray = UnkeyedContainer(values: [
            "nesting",
            "arrays",
            "natch",
        ])

        XCTAssertEqual(values.values[9].value as? UnkeyedContainer, expectedArray, "nested array")
    }
    
}
