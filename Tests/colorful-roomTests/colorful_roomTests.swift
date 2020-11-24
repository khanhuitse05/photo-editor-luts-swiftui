import XCTest
@testable import colorful_room

final class colorful_roomTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(colorful_room().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
