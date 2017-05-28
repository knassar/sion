//
//  ParserTests.swift
//  SIONTests
//
//  Created by Karim Nassar on 5/20/17.
//  Copyright © 2017 HungryMelonStudios LLC. All rights reserved.
//

import XCTest
@testable import SION

func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ min: Int = 0, _ sec: Int = 0) -> Date? {
    var date = DateComponents()
    date.calendar = Calendar.current
    date.timeZone = TimeZone(abbreviation: "GMT")
    date.year = year
    date.month = month
    date.day = day
    date.hour = hour
    date.minute = min
    date.second = sec
    
    return date.date
}

class ParserTests: XCTestCase {
    
    func testParse_util() {
        
        let p = Parser(raw: "abc 123 xyz")
        p.advance(2)
        XCTAssertEqual(p.peek(3), "c 1")
        p.advance(5)
        XCTAssertEqual(p.peek(8), " xyz")
     
        p.rewind()
        XCTAssertTrue(p.chompIf(matching: "ABC"))
        XCTAssertFalse(p.chompIf(matching: "123"))
        p.advance()
        XCTAssertTrue(p.chompIf(matching: "123"))

        p.rewind()
        XCTAssertEqual(p.accumulateWhile { $0 != "2" }, "abc 1")
    }
    
    func test_parseDate() {
        let p = Parser(raw: "")
        XCTAssertEqual(p.parseDate("2017-05-27"), date(2017, 5, 27))
        XCTAssertEqual(p.parseDate("2017/05/27"), date(2017, 5, 27))
        
        XCTAssertEqual(p.parseDate("2017-05-27 10:50:32"), date(2017, 5, 27, 10, 50, 32))
        XCTAssertEqual(p.parseDate("2017/05/27 10:50:32"), date(2017, 5, 27, 10, 50, 32))
    }
    
    func testParse_empty() {
        var empty: SION
        
        empty = try! Parser.parse("")
        XCTAssertTrue(empty.isEmpty)

        empty = try! Parser.parse("    \n \n  \t     \n")
        XCTAssertTrue(empty.isEmpty)

        empty = try! Parser.parse("   /* Foo Bar */   \n // Foo Bar")
        XCTAssertTrue(empty.isEmpty)
    }
    
    func testParse_dictionary() {
        var dict: SION

        dict = try! Parser.parse("{}")
        XCTAssertTrue(dict.isEmpty)

        dict = try! Parser.parse(" {\n \n }")
        XCTAssertTrue(dict.isEmpty)
        
        dict = try! Parser.parse(" {\n 'foo': 'bar' \n }")
        XCTAssertTrue(!dict.isEmpty)
        XCTAssertEqual(dict["foo"].stringValue, "bar")

        dict = try! Parser.parse(" {\n 'foo': 'bar',\n biff: \"bast\",\n date: 2017-04-01, /* Foo Bar */ \n dub: -23.56 }")
        XCTAssertTrue(!dict.isEmpty)
        XCTAssertEqual(dict["foo"].stringValue, "bar")
        XCTAssertEqual(dict["biff"].stringValue, "bast")
        XCTAssertEqual(dict["dub"].numberValue, -23.56)
        
        XCTAssertEqual(dict["date"].dateValue, date(2017, 4, 1))
    }
    
    func testParse_array() {
        var array: SION

        array = try! Parser.parse("[]")
        XCTAssertTrue(array.isEmpty)
        
        array = try! Parser.parse(" [\n \n ]")
        XCTAssertTrue(array.isEmpty)
        
        array = try! Parser.parse(" [\n 'bar' \n ]")
        XCTAssertTrue(!array.isEmpty)
        XCTAssertEqual(array[0].stringValue, "bar")
 
        array = try! Parser.parse(" [\n 'bar',\n \"bast\", \n -23.56, {\n bar: 'foo' \n} \n]")
        XCTAssertTrue(!array.isEmpty)
        XCTAssertEqual(array[0].stringValue, "bar")
        XCTAssertEqual(array[1].stringValue, "bast")
        XCTAssertEqual(array[2].numberValue, -23.56)
        XCTAssertEqual(array[3]["bar"].stringValue, "foo")

    }
    
    func test_overallParse() {
        let testBundle = Bundle(for: type(of: self))
        guard
            let filePath = testBundle.path(forResource: "test", ofType: "sion"),
            let string = try? String(contentsOfFile: filePath)
            else { return XCTFail() }
        print(string)
        let test = try! Parser.parse(string)
        XCTAssertFalse(test.isEmpty)

        XCTAssertEqual(test["json"]["string"].string, "foo")
        XCTAssertEqual(test["json"]["number"].number, 1234.9012)
        XCTAssertTrue(test["json"]["boolean"].boolValue)
        XCTAssertEqual(test["json"]["nothin"].type, .null)
        XCTAssertEqual(test["json"]["array"].arrayValue.count, 3)
        XCTAssertEqual(test["json"]["array"][1].string, "b")
        XCTAssertEqual(test["json"]["dict"]["arr"][1].number, 2)
        XCTAssertEqual(test["json"]["dict"]["nil"].type, .null)
        XCTAssertTrue(test["json"]["dict"]["boo"].boolValue)

        XCTAssertEqual(test["keys"]["foo"].stringValue, "yay!", "we can skip quoting dictionary keys if there is no whitespace in them")
        XCTAssertEqual(test["keys"]["some \"key\""].stringValue, "cool", "plus we can use single quotes to avoid escaping doubles")
        XCTAssertEqual(test["keys"].dictionaryValue.count, 2, "trailing commas are safe")

        XCTAssertEqual(test["values"].arrayValue.count, 10, "values count")
        XCTAssertEqual(test["values"][0].stringValue, "pile o' strings", "double-quoted string")
        XCTAssertEqual(test["values"][1].stringValue, "and \"strings\"", "single-quoted string")
        XCTAssertEqual(test["values"][2].numberValue, -1234.2342, "numbers")
        XCTAssertEqual(test["values"][3].boolValue, true, "bool")
        XCTAssertEqual(test["values"][4].bool, false, "bool")
        XCTAssertEqual(test["values"][5].type, .null, "null")
        XCTAssertEqual(test["values"][6].dateValue, date(2013, 6, 13), "date literals!")
        XCTAssertEqual(test["values"][7].dateValue, date(2011, 1, 10, 8, 1, 0), "date time literals!")
        XCTAssertEqual(test["values"][8].dictionaryValue.count, 1, "nesting dictionaries")
        XCTAssertEqual(test["values"][8]["nesting"].stringValue, "dictionaries", "nesting dictionaries")
        XCTAssertEqual(test["values"][9].arrayValue.count, 3, "nesting arrays")
        XCTAssertEqual(test["values"][9][1].stringValue, "arrays", "nesting arrays")

    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
