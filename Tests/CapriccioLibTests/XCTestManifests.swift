import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        FeatureFilesFetcherTests.allTests
    ]
}
#endif
