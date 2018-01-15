//
//  SION+ComparisonTests.swift
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

class SION_ComparisonTests: XCTestCase {

    lazy var testSION: SION = {
        let testBundle = Bundle(for: type(of: self))
        let filePath = testBundle.path(forResource: "test", ofType: "sion")!
        let string = try! String(contentsOfFile: filePath)
        return try! Parser.parse(string)
    }()

    func test_hashValue() {
        XCTAssertNotEqual(testSION.hashValue, 0)

        var empty = SION()
        empty.type = .string
        XCTAssertEqual(empty.hashValue, 0)
        empty.type = .number
        XCTAssertEqual(empty.hashValue, 0)
        empty.type = .bool
        XCTAssertEqual(empty.hashValue, 0)
        empty.type = .array
        XCTAssertNotEqual(empty.hashValue, 0)
        empty.type = .dictionary
        XCTAssertNotEqual(empty.hashValue, 0)
        empty.type = .date
        XCTAssertEqual(empty.hashValue, 0)

        XCTAssertEqual(SION("foo").hashValue, SION("foo").hashValue)
        XCTAssertEqual(SION(123).hashValue, SION(123).hashValue)
        XCTAssertEqual(SION(true).hashValue, SION(true).hashValue)
    }

    func test_equality() {

        XCTAssertTrue(SION("foo") == SION("foo"))
        XCTAssertTrue(SION(true) == SION(true))
        XCTAssertTrue(SION(123) == SION(123.0))
        let now = Date()
        XCTAssertTrue(SION(now) == SION(now))

        XCTAssertTrue(SION(["foo", true]) == SION(["foo", true]))
        XCTAssertFalse(SION(["foo", false]) == SION(["foo"]))
        XCTAssertFalse(SION(["foo", true]) == SION(["foo", false]))

        XCTAssertTrue(SION(["foo": true, "bar": 123]) == SION(["foo": true, "bar": 123]))
        XCTAssertFalse(SION(["foo": true, "bar": false]) == SION(["foo": true, "bar": "bast"]))
        XCTAssertFalse(SION(["foo": true, "bar": false]) == SION(["foo": true]))
        let otherSION = try! SION(raw: testSION.stringify())
        XCTAssertTrue(testSION == otherSION)

        let undef = SION.undefined
        XCTAssertFalse(undef == undef)
    }

    func test_dictionaryOrderImpactOnEquality() {

        let orderedDict1 = try! SION(raw: """
            {
                foo: "bar",
                bar: true,
                bast: 123,
                biff: null,
            }
            """)

        let orderedDict2 = SION([
            "foo": "bar",
            "bar": true,
            "bast": 123,
            "biff": SION.null,
            ])

        let orderedDict3 = try! SION(raw: """
            {
                foo: "bar",
                bast: 123,
                bar: true,
                biff: null,
            }
            """)

        let unorderedDict1 = SION(unorderedDictionary: [
            "foo": "bar",
            "bar": true,
            "bast": 123,
            "biff": SION.null,
            ])

        let unorderedDict2 = SION(unorderedDictionary: [
            "foo": "bar",
            "bar": true,
            "bast": 123,
            "biff": SION.null,
            ])

        // order of dictionary keys doesn't impact equality
        XCTAssertEqual(orderedDict1, unorderedDict1)
        XCTAssertEqual(orderedDict1, orderedDict2)

        // explicityly testing order
        // parsed from raw or initialized from literal is order-preserving by default
        XCTAssertTrue(orderedDict1.isOrderedSame(as: orderedDict2))
        XCTAssertFalse(orderedDict1.isOrderedSame(as: orderedDict3))

        // unordered dictionaries can't guarantee order
        XCTAssertFalse(orderedDict1.isOrderedSame(as: unorderedDict1))
        XCTAssertFalse(orderedDict1.isOrderedSame(as: unorderedDict2))
        XCTAssertFalse(unorderedDict1.isOrderedSame(as: unorderedDict2))

        // ordering test on arrays just test equality because equality for array already tests order
        XCTAssertTrue(SION([1, 2, 3]).isOrderedSame(as: SION([1, 2, 3])))
        XCTAssertFalse(SION([1, 2, 3]).isOrderedSame(as: SION([1, true, 3])))

    }

}
