//
//  colorful_roomTests.swift
//  colorful-roomTests
//
//  Created by Ping9 on 10/10/2021.
//

import ObjectiveC.runtime
@preconcurrency import PixelEnginePackage
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

    @MainActor
    func testRecipeAllFilterTypesAndEdgeCases() throws {
        guard let sample = UIImage(named: "sample-image") ?? UIImage(named: "carem") else {
            XCTFail("Expected sample-image or carem in bundle")
            return
        }

        // Verify decimal HLS vector parsing works regardless of device locale
        let parsed = RecipeUtils.stringToArrayVector("0.1,1.2,1.0;0.0,1.0,1.0")
        XCTAssertEqual(Double(parsed[0].x), 0.1, accuracy: 0.001)
        XCTAssertEqual(Double(parsed[0].y), 1.2, accuracy: 0.001)
        XCTAssertEqual(Double(parsed[0].z), 1.0, accuracy: 0.001)
        XCTAssertEqual(Double(parsed[1].y), 1.0, accuracy: 0.001)

        let ctl = PECtl()
        ctl.setImage(image: sample)
        XCTAssertNotNil(ctl.previewImage)

        // 1. Recipe with NO LUT, only Exposure +0.5
        ctl.didReceive(action: .applyFilter({
            var exp = FilterExposure()
            exp.value = 0.5
            $0.exposure = exp
        }))
        let expRecipe = try XCTUnwrap(RecipeUtils.addRecipe("ExpOnly", filters: ctl.editState.currentEdit.filters))

        // 2. Recipe with HLS
        var hls = FilterHLS()
        var shifts = FilterHLS.defaultValue
        shifts[0] = CIVector(x: 0.1, y: 1.2, z: 1.0)
        hls.inputShift = shifts
        ctl.didReceive(action: .applyFilter({ $0.hls = hls }))
        let hlsRecipe = try XCTUnwrap(RecipeUtils.addRecipe("HLSOnly", filters: ctl.editState.currentEdit.filters))

        // 3. Recipe with raw CoreData defaults (colorValueContrast=0, colorValueSaturation=0)
        let ctx = PersistenceController.shared.container.viewContext
        let rawDefaultRecipe = RecipeObject(context: ctx)
        rawDefaultRecipe.recipeName = "RawDefault"
        try ctx.save()

        let smallCI = resizedImage(at: ctl.originCI, scale: DesignTokens.thumbnailScale / sample.size.height, aspectRatio: 1)

        // Apply each to fresh controller and verify both main preview and recipe thumbnail
        for (name, obj) in [("ExpOnly", expRecipe), ("HLSOnly", hlsRecipe), ("RawDefault", rawDefaultRecipe)] {
            let recipeModel = Recipe(data: obj)
            recipeModel.setImage(image: smallCI)
            XCTAssertNotNil(recipeModel.preview, "\(name) thumbnail preview should not be nil")

            let fresh = PECtl()
            fresh.setImage(image: sample)
            fresh.onApplyRecipe(obj)
            XCTAssertNotNil(fresh.currentRecipe)
            XCTAssertEqual(fresh.lutsCtrl.currentCube, obj.lutIdentifier ?? "")

            let img = try XCTUnwrap(fresh.previewImage, "\(name) previewImage should not be nil")
            let cg = try XCTUnwrap(img.cgImage)
            let data = try XCTUnwrap(cg.dataProvider?.data)
            let ptr = CFDataGetBytePtr(data)!
            let len = CFDataGetLength(data)
            var minByte: UInt8 = 255
            var maxByte: UInt8 = 0
            for i in stride(from: 0, to: min(len, 4000), by: 4) {
                minByte = min(minByte, ptr[i], ptr[i+1], ptr[i+2])
                maxByte = max(maxByte, ptr[i], ptr[i+1], ptr[i+2])
            }
            XCTAssertGreaterThan(maxByte - minByte, 20, "\(name) should preserve visible image detail rather than rendering flat/black")

            // Selecting a new photo clears currentRecipe
            fresh.setImage(image: sample)
            XCTAssertNil(fresh.currentRecipe, "setImage should clear currentRecipe for the new photo")

            _ = RecipeUtils.deleteRecipe(obj)
        }
    }

    @MainActor
    func testRecipePreviewAndApply() throws {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
        let testImage = renderer.image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
        }

        let ctl = PECtl()
        ctl.setImage(image: testImage)

        // Apply a LUT filter
        let lut = Data.shared.cubeBy(identifier: "Cinematic-1")
        XCTAssertNotNil(lut, "Cinematic-1 LUT should load")
        ctl.didReceive(action: .applyFilter({ $0.colorCube = lut }))

        // Save recipe
        let recipeObj = try XCTUnwrap(RecipeUtils.addRecipe("TestCinematic", filters: ctl.editState.currentEdit.filters))
        let recipe = Recipe(data: recipeObj)
        let smallCI = resizedImage(at: ctl.originCI, scale: DesignTokens.thumbnailScale / testImage.size.height, aspectRatio: 1)
        XCTAssertNotNil(smallCI)
        recipe.setImage(image: smallCI)
        XCTAssertNotNil(recipe.preview, "Recipe thumbnail preview should not be nil")

        // Reset to a fresh image and apply the saved recipe
        let ctl2 = PECtl()
        ctl2.setImage(image: testImage)
        ctl2.onApplyRecipe(recipeObj)
        XCTAssertNotNil(ctl2.previewImage, "previewImage should be updated immediately upon onApplyRecipe")
        XCTAssertEqual(ctl2.lutsCtrl.currentCube, "Cinematic-1")

        _ = RecipeUtils.deleteRecipe(recipeObj)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
