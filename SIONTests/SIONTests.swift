//
//  SIONTests.swift
//  SION
//
//  Created by Karim Nassar on 5/28/17.
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

class SIONTests : XCTestCase {

    func test_rawInit() {
        let rawStr = " {\n 'foo': 'bar',\n biff: \"bast\",\n date: 2017-04-01, /* Foo Bar */ \n dub: -23.56 }"
        let sion = try! SION(raw: rawStr)
        XCTAssertEqual(sion["foo"].stringValue, "bar")
        XCTAssertEqual(sion["biff"].stringValue, "bast")
        XCTAssertEqual(sion["date"].dateValue, date(2017, 4, 1))
        XCTAssertEqual(sion["dub"].numberValue, -23.56)

        let sion2 = try! SION(data: rawStr.data(using: .utf8)!)
        XCTAssertEqual(sion2["foo"].stringValue, "bar")
        XCTAssertEqual(sion2["biff"].stringValue, "bast")
        XCTAssertEqual(sion2["date"].dateValue, date(2017, 4, 1))
        XCTAssertEqual(sion2["dub"].numberValue, -23.56)

        do {
            _ = try SION(raw: "{ ")
            XCTFail()
        }
        catch let err as SION.Error {
            switch err {
            case let .syntax(description: _, context: context):
                XCTAssertEqual(context, "{ ")
            default:
                XCTFail()
            }
        }
        catch {
            XCTFail()
        }

        do {
            _ = try SION(data: Data(bytes: [0xFF, 0xD9] as [UInt8]))
            XCTFail()
        }
        catch let err as SION.Error {
            switch err {
            case .stringFromData:
                break
            default:
                XCTFail()
            }
        }
        catch {
            XCTFail()
        }

    }

    func test_isEmpty() {
        XCTAssertTrue(SION().isEmpty)
        XCTAssertTrue(SION.undefined.isEmpty)
        XCTAssertTrue(SION.null.isEmpty)
        XCTAssertTrue(SION([SION]()).isEmpty)
        XCTAssertTrue(SION(unorderedDictionary: [String: SION]()).isEmpty)
        XCTAssertTrue(SION("").isEmpty)

        XCTAssertFalse(SION("x").isEmpty)
        XCTAssertFalse(SION(true).isEmpty)
        XCTAssertFalse(SION(false).isEmpty)
        XCTAssertFalse(SION(123).isEmpty)
        XCTAssertFalse(SION(0).isEmpty)
        XCTAssertFalse(SION(Date()).isEmpty)
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

        let sionArr = SION([
            1234,
            true,
            SION(d),
            SION(["foo": "bar"])
            ])
        XCTAssertEqual(sionArr[0].intValue, 1234)
        XCTAssertEqual(sionArr[1].boolValue, true)
        XCTAssertEqual(sionArr[2].dateValue, d)
        XCTAssertEqual(sionArr[3]["foo"].stringValue, "bar")
        
    }
    
}
