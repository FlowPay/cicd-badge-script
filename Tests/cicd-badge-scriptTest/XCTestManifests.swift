import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(linter_scriptTests.allTests),
    ]
}
#endif
