import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(colorful_roomTests.allTests),
    ]
}
#endif
