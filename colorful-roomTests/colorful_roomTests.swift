//
//  colorful_roomTests.swift
//  colorful-roomTests
//
//  Created by Ping9 on 10/10/2021.
//

import XCTest
@testable import colorful_room

class colorful_roomTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSliderValueConversion() throws {
        // Range -1 to 1 (like Shadows)
        let range = (-1.0, 1.0)
        let display = (-100.0, 100.0)
        
        // Min value
        XCTAssertEqual((-1.0).convert(fromRange: range, toRange: display), -100.0)
        // Mid value
        XCTAssertEqual((0.0).convert(fromRange: range, toRange: display), 0.0)
        // Max value
        XCTAssertEqual((1.0).convert(fromRange: range, toRange: display), 100.0)
        
        // Dragging left (lower pixel X) must yield lower value
        let leftPixelX = 50.0
        let rightPixelX = 250.0
        let pixelRange = (10.0, 290.0) // 10 to 290 travel
        
        let leftVal = leftPixelX.convert(fromRange: pixelRange, toRange: range)
        let rightVal = rightPixelX.convert(fromRange: pixelRange, toRange: range)
        
        XCTAssertLessThan(leftVal, rightVal, "Dragging left must yield smaller value than dragging right")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
