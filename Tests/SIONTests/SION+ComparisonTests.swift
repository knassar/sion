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
        let url = Bundle.module.url(forResource: "test", withExtension: "sion")!
        let data = try! Data(contentsOf: url)
        return try! SION(data: data)
    }()

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
        let otherSION = try! SION(raw: testSION.rawString!)
        XCTAssertEqual(testSION, otherSION)

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

        let unorderedDict1 = SION([
            "bar": true,
            "biff": SION.null,
            "foo": "bar",
            "bast": 123,
            ])

        // order of dictionary keys doesn't impact equality
        XCTAssertNotEqual(orderedDict1, unorderedDict1)
        XCTAssertEqual(orderedDict1, orderedDict2)

        // explicityly testing order
        // parsed from raw or initialized from literal is order-preserving by default
        XCTAssertTrue(orderedDict1 == orderedDict2)
        XCTAssertFalse(orderedDict1 == orderedDict3)
        XCTAssertFalse(orderedDict1 == unorderedDict1)

        // ordering test on arrays just test equality because equality for array already tests order
        XCTAssertTrue(SION([1, 2, 3]) == SION([1, 2, 3]))
        XCTAssertFalse(SION([1, 2, 3]) == SION([1, 3, 2]))
        XCTAssertFalse(SION([1, 2, 3]) == SION([1, true, 3]))

    }

}
