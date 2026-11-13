//
//  Utility.swift
//  colorful-room
//
//  Created by Ping9 on 8/3/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import Foundation
import Metal
import ObjectiveC.runtime
import UIKit

/// Runtime compatibility patches for Apple GPU driver bugs.
enum MetalDriverCompatibility {
    private static let installOnce: Void = {
        // Ensure Metal and its hardware driver bundle (e.g. AGXMetalA13) are loaded before patching.
        _ = MTLCreateSystemDefaultDevice()

        let selector = NSSelectorFromString("resourceIndex")
        let block: @convention(block) (AnyObject) -> UInt64 = { _ in 0 }
        let safeIMP = imp_implementationWithBlock(block)
        let typeEncoding = "Q@:"

        // `_MTLFunctionHandle` defines `-resourceIndex` as a `doesNotRecognizeSelector:` stub
        // for subclasses to override. On A13 devices (iPhone 11 series), `AGXA13FamilyFunctionHandle`
        // omits the override, so calling `-resourceIndex` (e.g. from CoreImage or Metal API Validation)
        // hits `_MTLFunctionHandle`'s stub and throws `NSInvalidArgumentException`.
        // Replacing `_MTLFunctionHandle`'s stub leaves A14+ overrides untouched while safely returning 0 on A13.
        if let baseClass = NSClassFromString("_MTLFunctionHandle") {
            if let method = class_getInstanceMethod(baseClass, selector) {
                method_setImplementation(method, safeIMP)
            } else {
                class_addMethod(baseClass, selector, safeIMP, typeEncoding)
            }
        }

        if let a13Class = NSClassFromString("AGXA13FamilyFunctionHandle") {
            class_replaceMethod(a13Class, selector, safeIMP, typeEncoding)
        }
    }()

    /// Installs runtime Metal driver workarounds once per process.
    static func install() {
        _ = installOnce
    }
}

class Utils{
    static func loadShopurtUrl(){
        
    }
}
