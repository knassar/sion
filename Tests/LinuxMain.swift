import XCTest

import sionTests

var tests = [XCTestCaseEntry]()
tests += ASTParserTests.allTests()
tests += SION_AccessorsTests.allTests()
tests += SION_ComparisonTests.allTests()
tests += SION_StringifyTests.allTests()

XCTMain(tests)
