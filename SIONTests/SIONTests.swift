//
//  SIONTests.swift
//  SION
//
//  Created by Karim Nassar on 5/28/17.
//  Copyright © 2017 HungryMelonStudios LLC. All rights reserved.
//

import XCTest
@testable import SION

class SIONTests : XCTestCase {

    func test_rawInit() {
        let sion = try! SION(raw: " {\n 'foo': 'bar',\n biff: \"bast\",\n date: 2017-04-01, /* Foo Bar */ \n dub: -23.56 }")
        
        XCTAssertEqual(sion["foo"].stringValue, "bar")
        XCTAssertEqual(sion["biff"].stringValue, "bast")
        XCTAssertEqual(sion["date"].dateValue, date(2017, 4, 1))
        XCTAssertEqual(sion["dub"].numberValue, -23.56)
        
    }

    func test_KeyPaths() {
        let sion = try! SION(raw: "{foo: {bar: {biff: [{}, {boff: 'perfect'}]}}}")

        XCTAssertEqual(sion["foo", "bar", "biff", 1, "boff"].stringValue, "perfect")
        
        let keypath: [SIONKey] = ["foo", "bar", "biff", 1, "boff"]
        XCTAssertEqual(sion[keypath].stringValue, "perfect")
    }
}
