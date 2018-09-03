import XCTest
@testable import Capriccio

final class CapriccioTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Capriccio().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
