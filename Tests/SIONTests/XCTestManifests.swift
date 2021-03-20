import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ASTParserTests.allTests),
        testCase(CharacterSet_UtilsTests.allTests),
        testCase(SION_AccessorsTests.allTests),
        testCase(SION_ComparisonTests.allTests),
        testCase(SION_StringifyTests.allTests),
    ]
}
#endif
