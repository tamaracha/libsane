import XCTest
@testable import libsane

class libsaneTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(libsane().text, "Hello, World!")
    }


    static var allTests : [(String, (libsaneTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
