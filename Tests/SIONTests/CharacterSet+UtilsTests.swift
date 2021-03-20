//
//  CharacterSet+UtilsTests.swift
//  SIONTests
//
//  Created by Karim Nassar on 5/20/17.
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
import Foundation
@testable import SION

class CharacterSet_UtilsTests: XCTestCase {

    func test_hasMember() {
        XCTAssertTrue(CharacterSet.alphanumerics.hasMember("a"))
        XCTAssertTrue(CharacterSet.alphanumerics.hasMember("b"))
        XCTAssertTrue(CharacterSet.alphanumerics.hasMember("C"))
        XCTAssertTrue(CharacterSet.alphanumerics.hasMember("1"))
        XCTAssertTrue(CharacterSet.alphanumerics.hasMember("0"))

        XCTAssertFalse(CharacterSet.alphanumerics.hasMember("_"))
        XCTAssertFalse(CharacterSet.alphanumerics.hasMember(";"))
        XCTAssertFalse(CharacterSet.alphanumerics.hasMember("%"))
    }

    func test_containsMember() {
        XCTAssertTrue("abcdefg".containsMember(of: .alphanumerics))
        XCTAssertTrue("abc.;%".containsMember(of: .alphanumerics))
        XCTAssertTrue("%DF".containsMember(of: .alphanumerics))
        XCTAssertFalse("%^%$#".containsMember(of: .alphanumerics))
    }

}
