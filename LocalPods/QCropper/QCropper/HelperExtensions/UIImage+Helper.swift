//
//  UIImage+Helper.swift
//
//  Created by Chen Qizhi on 2019/10/15.
//

import UIKit

extension UIImage {

    // MARK: Custom UI

    @available(*, deprecated, message: "use init(color:size:traitCollection:) instead")
    convenience init(color: UIColor, size: CGSize) {
        self.init(color: color, size: size, traitCollection: .current)
    }

    convenience init(color: UIColor, size: CGSize, traitCollection: UITraitCollection) {
        let format = UIGraphicsImageRendererFormat(for: traitCollection)
        format.opaque = false
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        guard let cgImage = image.cgImage else {
            self.init()
            return
        }

        self.init(cgImage: cgImage)
    }
}
