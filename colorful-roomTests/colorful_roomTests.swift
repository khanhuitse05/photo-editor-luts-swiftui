//
//  colorful_roomTests.swift
//  colorful-roomTests
//
//  Created by Ping9 on 10/10/2021.
//

import ObjectiveC.runtime
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

    @MainActor
    func testSetImageProducesImmediatePreview() throws {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
        let testImage = renderer.image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
        }

        let ctl = PECtl()
        ctl.setImage(image: testImage)

        XCTAssertNotNil(ctl.originUI, "originUI should be set immediately")
        XCTAssertNotNil(ctl.originCI, "originCI should be set immediately")
        XCTAssertNotNil(ctl.previewImage, "previewImage must be non-nil immediately upon setImage")
        XCTAssertNotNil(ctl.originalPreview, "originalPreview must be non-nil immediately upon setImage")
    }

    func testConvertUItoCIOriginZero() throws {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 150))
        let testImage = renderer.image { ctx in
            UIColor.blue.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 100, height: 150))
        }

        let ciImage = convertUItoCI(from: testImage)
        XCTAssertEqual(ciImage.extent.origin, .zero, "convertUItoCI must guarantee origin at (0, 0)")
        XCTAssertGreaterThan(ciImage.extent.width, 0)
        XCTAssertGreaterThan(ciImage.extent.height, 0)
    }

    func testMetalFunctionHandleResourceIndexCompatibility() throws {
        MetalDriverCompatibility.install()

        guard let baseClass = NSClassFromString("_MTLFunctionHandle") else {
            return
        }

        let subclassName = "TestUnimplementedFunctionHandle_\(UUID().uuidString.replacingOccurrences(of: "-", with: "_"))"
        guard let subclass = objc_allocateClassPair(baseClass, subclassName, 0) else {
            XCTFail("Failed to allocate test subclass of _MTLFunctionHandle")
            return
        }
        objc_registerClassPair(subclass)

        guard let nsType = subclass as? NSObject.Type else {
            XCTFail("Expected _MTLFunctionHandle subclass to inherit from NSObject")
            return
        }

        let instance = nsType.init()
        let selector = NSSelectorFromString("resourceIndex")
        XCTAssertTrue(instance.responds(to: selector))

        let method = class_getInstanceMethod(subclass, selector)
        XCTAssertNotNil(method)
        if let method = method {
            typealias ResourceIndexIMP = @convention(c) (AnyObject, Selector) -> UInt64
            let fn = unsafeBitCast(method_getImplementation(method), to: ResourceIndexIMP.self)
            XCTAssertEqual(fn(instance, selector), 0, "Fallback resourceIndex on _MTLFunctionHandle must safely return 0")
        }
    }

    func testHasCustomHLS() throws {
        XCTAssertFalse(RecipeUtils.hasCustomHLS(nil), "nil HLS is not custom")
        XCTAssertFalse(RecipeUtils.hasCustomHLS(""), "empty HLS is not custom")
        
        let defaultStr = "0,1,1;0,1,1;0,1,1;0,1,1;0,1,1;0,1,1;0,1,1;0,1,1"
        XCTAssertFalse(RecipeUtils.hasCustomHLS(defaultStr), "default vectors must not be considered custom")

        let customStr = "0.2,1,1;0,1,1;0,1,1;0,1,1;0,1,1;0,1,1;0,1,1;0,1,1"
        XCTAssertTrue(RecipeUtils.hasCustomHLS(customStr), "modified shift must be detected as custom")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
