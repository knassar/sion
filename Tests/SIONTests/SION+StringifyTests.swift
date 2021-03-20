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

    func test_stringifyJSON() {
        let rawString = """
             {
               'foo': 'bar',
                biff: "bast",
                date: 2017-04-01, /* Foo Bar */
                array: ["foo", 'bar', true, false, null],
                dub: -23.56,
                "and then": "foo'bar",
                "and plus": 'foo"bar',
            }
            """
        let sion = try! SION(parsing: rawString)

        let json = """
            {"foo":"bar","biff":"bast","date":"2017-04-01 00:00:00","array":["foo","bar",true,false,null],"dub":-23.56,"and then":"foo'bar","and plus":"foo\\\"bar"}
            """
        XCTAssertEqual(sion.stringify(options: .json), json)

        let jsonSorted = """
            {"and plus":"foo\\"bar","and then":"foo'bar","array":["foo","bar",true,false,null],"biff":"bast","date":"2017-04-01 00:00:00","dub":-23.56,"foo":"bar"}
            """
        XCTAssertEqual(sion.stringify(options: [.json, .sortKeys]), jsonSorted)

        let prettySorted = """
            {
                "and plus": "foo\\\"bar",
                "and then": "foo'bar",
                "array": [
                    "foo",
                    "bar",
                    true,
                    false,
                    null
                ],
                "biff": "bast",
                "date": "2017-04-01 00:00:00",
                "dub": -23.56,
                "foo": "bar"
            }
            """
        XCTAssertEqual(sion.stringify(options: [.json, .pretty, .sortKeys]), prettySorted)

        let pretty = """
            {
                "foo": "bar",
                "biff": "bast",
                "date": "2017-04-01 00:00:00",
                "array": [
                    "foo",
                    "bar",
                    true,
                    false,
                    null
                ],
                "dub": -23.56,
                "and then": "foo'bar",
                "and plus": "foo\\\"bar"
            }
            """
        XCTAssertEqual(sion.stringify(options: [.json, .pretty]), pretty)
    }

    func test_stringify() {
        let rawString = """
            {
               'foo': 'bar',
                biff: "bast",
                date: 2017-04-01, /* Foo Bar */
                array: ["foo", 'bar', true, false, null],
                dub: -23.56, // line
                "and then": "foo'bar",
                "and plus": 'foo"bar'
            }
            """
        let sion = try! SION(parsing: rawString)

        let jsonSorted = """
            {"and plus":'foo"bar',"and then":"foo'bar",array:["foo","bar",true,false,null,],biff:"bast",date:2017-04-01 00:00:00,dub:-23.56,foo:"bar",}
            """
        XCTAssertEqual(sion.stringify(options: [.sortKeys]), jsonSorted)

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
            foo: "bar",
        }
        """

        XCTAssertEqual(sion.stringify(options: [.pretty, .sortKeys, .stripComments]), prettySorted)

        let prettyOrderPreserved = """
        {
            foo: "bar",
            biff: "bast",
            date: 2017-04-01 00:00:00, /* Foo Bar */
            array: [
                "foo",
                "bar",
                true,
                false,
                null,
            ],
            dub: -23.56, // line
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
            foo: "bar"
        }
        """
        XCTAssertEqual(sion.stringify(options: [.pretty, .noTrailingComma, .sortKeys, .stripComments]), prettySortedNoTrailing)
    }

    func test_stringifyUndefined() {
        XCTAssertEqual(SION().stringify(), "")
        XCTAssertEqual(SION().stringify(options: [.json]), "")
    }

    func test_printKey_JSON() {
        func key(_ key: String) -> Key {
            Key(name: key, headComments: [], tailComments: [])
        }

        XCTAssertEqual(JSONPrinter(options: []).printKey(key("key")), "\"key\"")
        XCTAssertEqual(JSONPrinter(options: []).printKey(key("ke y")), "\"ke y\"")
        XCTAssertEqual(JSONPrinter(options: []).printKey(key("ke\"y")), "\"ke\\\"y\"")
        XCTAssertEqual(JSONPrinter(options: []).printKey(key("ke'y")), "\"ke'y\"")
        XCTAssertEqual(JSONPrinter(options: []).printKey(key("k\"e\"y")), "\"k\\\"e\\\"y\"")
        XCTAssertEqual(JSONPrinter(options: []).printKey(key("k'e'y")), "\"k'e'y\"")
        XCTAssertEqual(JSONPrinter(options: []).printKey(key("k'e\"y")), "\"k'e\\\"y\"")
        XCTAssertEqual(JSONPrinter(options: []).printKey(key("k:ey")), "\"k:ey\"")
        XCTAssertEqual(JSONPrinter(options: []).printKey(key("k:e\"y")), "\"k:e\\\"y\"")
        XCTAssertEqual(JSONPrinter(options: []).printKey(key("k:'e\"y")), "\"k:'e\\\"y\"")
    }

    func test_printKeySION() {
        func key(_ key: String) -> Key {
            Key(name: key, headComments: [], tailComments: [])
        }

        XCTAssertEqual(SIONPrinter(options: []).printKey(key("key")), "key")
        XCTAssertEqual(SIONPrinter(options: []).printKey(key("ke y")), "\"ke y\"")
        XCTAssertEqual(SIONPrinter(options: []).printKey(key("ke\"y")), "ke\"y")
        XCTAssertEqual(SIONPrinter(options: []).printKey(key("ke'y")), "ke'y")
        XCTAssertEqual(SIONPrinter(options: []).printKey(key("k\"e\"y")), "k\"e\"y")
        XCTAssertEqual(SIONPrinter(options: []).printKey(key("k'e'y")), "k'e'y")
        XCTAssertEqual(SIONPrinter(options: []).printKey(key("k'e\"y")), "k'e\"y")
        XCTAssertEqual(SIONPrinter(options: []).printKey(key("k:ey")), "\"k:ey\"")
        XCTAssertEqual(SIONPrinter(options: []).printKey(key("k:e\"y")), "'k:e\"y'")
        XCTAssertEqual(SIONPrinter(options: []).printKey(key("k:'e\"y")), "\"k:'e\\\"y\"")
    }

    func test_escapeDoubleQuotes() {

        struct DummyPrinter: Printer {
            let options: StringifyOptions

            private(set) var depth = 0
            private var currentPath = ""

            init(options: StringifyOptions) {
                self.options = options
            }

            func print(_ node: SION) throws -> String {
                return ""
            }
        }

        XCTAssertEqual(DummyPrinter(options: .json).escapeDoubleQuotes("fo o'b ar \\ \"\" \\\" '\""), "fo o'b ar \\ \\\"\\\" \\\" '\\\"")
        XCTAssertEqual(DummyPrinter(options: .json).escapeDoubleQuotes("foo\"bar"), "foo\\\"bar")

    }

    func test_stringifyRootComments() {
        var sion = try! SION(parsing: """
            {
               'foo': 'bar',
                biff: "bast",
            }
            """)

        sion.addHeadComment("head block", preferBlock: true)
        sion.addHeadComment("head line")
        sion.addHeadComment("""
        head
        implicit
        block
        """)

        sion.addTailComment("tail block", preferBlock: true)
        sion.addTailComment("tail line")
        sion.addTailComment("""
        tail
        implicit
        block
        """)

        let expected = """
            /*
              head block
            */
            // head line
            /*
              head
              implicit
              block
            */
            {
                foo: "bar",
                biff: "bast",
            }
            /*
              tail block
            */
            // tail line
            /*
              tail
              implicit
              block
            */
            """

        XCTAssertEqual(sion.stringify(options: [.pretty]), expected)
    }

    func test_stringifyValueComments() {

        var sion = SION([
                "one",
                true,
                SION([
                    "foo": "bar",
                    "biff": "boff",
                ]),
                "three",
                "four",
                5,
            ])

        sion[1].addHeadComment("inline before true")
        sion[1].addTailComment("line tail true")
        var keyed = sion[2].value as! KeyedContainer
        keyed.addHeadComment("key foo line", forKey: "foo")
        sion[2].value = keyed
        sion[2].biff.addTailComment("after boff")
        sion[4].addHeadComment("head block comment", preferBlock: true)
        sion[4].addTailComment("tail block comment", preferBlock: true)

        let expected = """
            [
                "one",
                // inline before true
                true, // line tail true
                {
                    // key foo line
                    foo: "bar",
                    biff: "boff", // after boff
                },
                "three",
                /*
                  head block comment
                */
                "four", /*
                  tail block comment
                */
                5.0,
            ]
            """

        XCTAssertEqual(sion.stringify(options: [.pretty]), expected)

    }

}
