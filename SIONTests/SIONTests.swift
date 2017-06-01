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
    
    func test_initializeRaw() {
        let d = Date()
        let sion = SION([
            "foo": "bar",
            "num": 1234,
            "boo": true,
            "dat": SION(d)
            ])
        XCTAssertEqual(sion["foo"].stringValue, "bar")
        XCTAssertEqual(sion["num"].intValue, 1234)
        XCTAssertEqual(sion["boo"].boolValue, true)
        XCTAssertEqual(sion["dat"].dateValue, d)

    }
    
    func test_stringify() {
        let sion = try! SION(raw: " {\n 'foo': 'bar',\n biff: \"bast\",\n date: 2017-04-01, /* Foo Bar */ \n dub: -23.56 }")
        XCTAssertEqual(sion.stringify([.json, .sortKeys]), "{\"biff\":\"bast\",\"date\":\"2017-04-01 00:00:00\",\"dub\":-23.56,\"foo\":\"bar\"}")
        XCTAssertEqual(sion.stringify([.pretty, .sortKeys]), "{\n    biff: \"bast\",\n    date: 2017-04-01 00:00:00,\n    dub: -23.56,\n    foo: \"bar\",\n}")
        XCTAssertEqual(sion.stringify([.pretty, .noTrailingComma, .sortKeys]), "{\n    biff: \"bast\",\n    date: 2017-04-01 00:00:00,\n    dub: -23.56,\n    foo: \"bar\"\n}")
    }
    
    func test_escapeDoubleQuotes() {
        
        let string = "fo o'b ar \\ \"\" \\\" '\""
        XCTAssertEqual(SION().escapeDoubleQuotes(string), "fo o'b ar \\ \\\"\\\" \\\" '\\\"")
        
    }
    
}
