//
//  SION+StringifyTests.swift
//  SIONTests
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

import XCTest
@testable import SION

class SION_StringifyTests: XCTestCase {

    func test_stringify() {
        let rawString = """
             {
               'foo': 'bar',
                biff: "bast",
                date: 2017-04-01, /* Foo Bar */
                noKeys: {},
                array: ["foo", 'bar', true, false, null],
                empty: [ ],
                dub: -23.56,
                "and then": "foo'bar",
                "and plus": 'foo"bar' }
            """
        let sion = try! SION(raw: rawString)

        let jsonSorted = """
            {"and plus":"foo\\"bar","and then":"foo'bar","array":["foo","bar",true,false,null],"biff":"bast","date":"2017-04-01 00:00:00","dub":-23.56,"empty":[],"foo":"bar","noKeys":{}}
            """
        XCTAssertEqual(sion.stringify(options: [.json, .sortKeys]), jsonSorted)

        let prettySorted = """
            {
                "and plus": 'foo"bar',
                "and then": "foo'bar",
                array: [
                    "foo",
                    "bar",
                    true,
                    false,
                    null,
                ],
                biff: "bast",
                date: 2017-04-01 00:00:00,
                dub: -23.56,
                empty: [
                ],
                foo: "bar",
                noKeys: {
                },
            }
            """
        XCTAssertEqual(sion.stringify(options: [.pretty, .sortKeys]), prettySorted)

        let prettyOrderPreserved = """
            {
                foo: "bar",
                biff: "bast",
                date: 2017-04-01 00:00:00,
                noKeys: {
                },
                array: [
                    "foo",
                    "bar",
                    true,
                    false,
                    null,
                ],
                empty: [
                ],
                dub: -23.56,
                "and then": "foo'bar",
                "and plus": 'foo"bar',
            }
            """
        XCTAssertEqual(sion.stringify(options: [.pretty]), prettyOrderPreserved)

        let prettySortedNoTrailing = """
            {
                "and plus": 'foo"bar',
                "and then": "foo'bar",
                array: [
                    "foo",
                    "bar",
                    true,
                    false,
                    null
                ],
                biff: "bast",
                date: 2017-04-01 00:00:00,
                dub: -23.56,
                empty: [
                ],
                foo: "bar",
                noKeys: {
                }
            }
            """
        XCTAssertEqual(sion.stringify(options: [.pretty, .noTrailingComma, .sortKeys]), prettySortedNoTrailing)
    }

    func test_stringifyUndefined() {
        XCTAssertEqual(SION().stringify(), "null /* value undefined */")
        XCTAssertEqual(SION().stringify(options: [.json]), "null")
    }

    func test_stringifyKey() {
        XCTAssertEqual(SION().stringifyKey("key", options: []), "key")
        XCTAssertEqual(SION().stringifyKey("key", options: [.json]), "\"key\"")
        XCTAssertEqual(SION().stringifyKey("ke y", options: []), "\"ke y\"")
        XCTAssertEqual(SION().stringifyKey("ke\"y", options: []), "ke\"y")
        XCTAssertEqual(SION().stringifyKey("ke'y", options: []), "ke'y")
        XCTAssertEqual(SION().stringifyKey("k\"e\"y", options: []), "k\"e\"y")
        XCTAssertEqual(SION().stringifyKey("k'e'y", options: []), "k'e'y")
        XCTAssertEqual(SION().stringifyKey("k'e\"y", options: []), "k'e\"y")
        XCTAssertEqual(SION().stringifyKey("k:ey", options: []), "\"k:ey\"")
        XCTAssertEqual(SION().stringifyKey("k:e\"y", options: []), "'k:e\"y'")
        XCTAssertEqual(SION().stringifyKey("k:'e\"y", options: []), "\"k:'e\\\"y\"")
    }

    func test_escapeDoubleQuotes() {

        let string = "fo o'b ar \\ \"\" \\\" '\""
        XCTAssertEqual(SION().escapeDoubleQuotes(string), "fo o'b ar \\ \\\"\\\" \\\" '\\\"")

    }

}
