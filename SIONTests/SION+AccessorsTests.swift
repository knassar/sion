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

    func test_setKey() {

        var sion = SION()
        sion["foo"] = "bar"
        sion["num"] = 123.4
        sion["tru"] = true
        sion["arr"] = SION([1, 2, 3])
        sion["dict"] = SION(["bar": "foo"])

        sion["dict"]["biff"] = SION(date(2017, 4, 31)!)

        XCTAssertEqual(sion["foo"].string, "bar")
        XCTAssertEqual(sion["num"].number, 123.4)
        XCTAssertTrue(sion["tru"].boolValue)
        XCTAssertEqual(sion["arr"][1].int, 2)
        XCTAssertEqual(sion["dict"]["bar"].string, "foo")

    }

    func test_getKeyPaths() {
        let sion = try! SION(raw: "{foo: {bar: {biff: [{}, {boff: 'perfect'}]}}}")

        XCTAssertEqual(sion["foo", "bar", "biff", 1, "boff"].stringValue, "perfect")

        let keypath: [SIONKey] = ["foo", "bar", "biff", 1, "boff"]
        XCTAssertEqual(sion[keypath].stringValue, "perfect")
    }

    func test_setKeyPaths() {
        var sion = try! SION(raw: "{foo: {bar: {}}}")

        sion["foo", "bar", "biff", 1, "boff"] = "perfect"
        XCTAssertEqual(sion["foo", "bar", "biff", 1, "boff"].stringValue, "perfect")

        let keypath: [SIONKey] = ["foo", "bar", "biff", 0, "boff"]
        sion[keypath] = "frist!"
        XCTAssertEqual(sion[keypath].stringValue, "frist!")
    }

    func test_float() {

        XCTAssertEqual(SION(Float(123.45)).float, Float(123.45))
        XCTAssertEqual(SION(123.45).floatValue, Float(123.45))
        XCTAssertEqual(SION("not a float").floatValue, 0.0)

    }

}
