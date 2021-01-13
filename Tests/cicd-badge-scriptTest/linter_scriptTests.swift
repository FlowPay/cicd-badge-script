import XCTest
@testable import linter_script

final class linter_scriptTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(linter_script().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
