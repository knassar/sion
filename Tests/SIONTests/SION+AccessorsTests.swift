//
//  SION+AccessorsTests.swift
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

class SION_AccessorsTests: XCTestCase {

    func test_setStringKey() {

        var sion = SION()
        sion["foo"] = "bar"
        sion["num"] = 123.4
        sion["tru"] = true
        sion["arr"] = SION([1, 2, 3])
        sion["dict"] = SION(["bar": "foo"])

        sion.dict.biff = SION(date(2017, 4, 31)!)

        XCTAssertEqual(sion.foo.string, "bar")
        XCTAssertEqual(sion.num.double, 123.4)
        XCTAssertTrue(sion.tru.boolValue)
        XCTAssertEqual(sion.arr[1].int, 2)
        XCTAssertEqual(sion.dict.bar.string, "foo")

    }

    func test_setDynamicMember() {

        var sion = SION()
        sion.foo = "bar"
        sion.num = 123.4
        sion.tru = true
        sion.arr = SION([1, 2, 3])
        sion.dict = SION(["bar": "foo"])

        sion.arr[3] = "three"
        sion.dict.biff = SION(date(2017, 4, 31)!)

        XCTAssertEqual(sion.foo.string, "bar")
        XCTAssertEqual(sion.num.double, 123.4)
        XCTAssertTrue(sion.tru.boolValue)
        XCTAssertEqual(sion.arr[0].int, 1)
        XCTAssertEqual(sion.arr[1].int, 2)
        XCTAssertEqual(sion.arr[2].int, 3)
        XCTAssertEqual(sion.dict.bar.string, "foo")

        XCTAssertEqual(sion.arr[3].string, "three")
        XCTAssertEqual(sion.dict.biff.date, date(2017, 4, 31)!)

    }

    func test_getKeyPaths() {
        let sion = try! SION(parsing: "{foo: {bar: {biff: [{}, {boff: 'perfect'}]}}}")

        XCTAssertEqual(sion.foo.bar.biff[1].boff.stringValue, "perfect")

        XCTAssertTrue(sion.foo.bar.biff[0].boff.isUndefined)
        XCTAssertEqual(sion.foo.bar.biff[1].boff.string, "perfect")
    }

    func test_setKeyPaths() {
        var sion = try! SION(parsing: "{foo: {bar: {}}}")

        sion.foo.bar.biff.boff = SION(["perfect"])
        sion.blah = SION([123])
        sion.blah[2] = 321
        XCTAssertFalse(sion.foo.bar.biff.boff[0].isNull)
        XCTAssertTrue(sion.foo.bar.biff.boff[1].isUndefined)
        XCTAssertEqual(sion.blah[0].int, 123)
        XCTAssertNil(sion.blah[1].int)
        XCTAssertEqual(sion.blah[2].int, 321)
        XCTAssertEqual(sion.foo.bar.biff.boff[0].string, "perfect")

        sion.foo.bar.biff.boff[1] = "frist!"
        XCTAssertEqual(sion.foo.bar.biff.boff[0].string, "perfect")
        XCTAssertEqual(sion.foo.bar.biff.boff[1].string, "frist!")

        sion.foo.bar.biff.boff[0] = "after"
        XCTAssertEqual(sion.foo.bar.biff.boff[0].string, "after")
        XCTAssertEqual(sion.foo.bar.biff.boff[1].string, "frist!")
    }

    func test_float() {

        XCTAssertEqual(SION(Float(123.45)).float, Float(123.45))
        XCTAssertEqual(SION(123.45).floatValue, Float(123.45))
        XCTAssertEqual(SION("not a float").floatValue, 0.0)

    }

    func test_rawRepresentableConversion() {
        let sion = try! SION(parsing: """
        {
            foo: bar,
            biff: boff,
            blargh: 12,
        }
        """)

        enum Foo: String {
            case be, bar, bast
        }

        enum Biff: String {
            case baff, boff, boof
        }

        enum Blargh: Double {
            case low = 1.5
            case medium = 12
            case high = 87.3
        }

        XCTAssertEqual(sion.foo.as(Foo.self), .bar)
        XCTAssertEqual(sion.biff.as(Biff.self), .boff)
        XCTAssertEqual(sion.blargh.as(Blargh.self), .medium)

    }

}
