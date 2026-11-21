//
//  HelperExtensions.swift
//
//  Created by Chen Qizhi on 2019/10/15.
//

import UIKit

extension CGRect {
    public init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - size.width / 2.0, y: center.y - size.height / 2.0, width: size.width, height: size.height)
    }

    public func isEqual(to other: CGRect, accuracy epsilon: CGFloat) -> Bool {
        return (abs(minX - other.minX) <= epsilon) &&
            (abs(minY - other.minY) <= epsilon) &&
            (abs(width - other.width) <= epsilon) &&
            (abs(height - other.height) <= epsilon)
    }
}

extension CGPoint {
    public func isEqual(to other: CGPoint, accuracy epsilon: CGFloat) -> Bool {
        return (abs(x - other.x) <= epsilon) &&
            (abs(y - other.y) <= epsilon)
    }
}

extension CGSize {
    public func isEqual(to other: CGSize, accuracy epsilon: CGFloat) -> Bool {
        return (abs(width - other.width) <= epsilon) &&
            (abs(height - other.height) <= epsilon)
    }
}

extension CGFloat {
    public func isEqual(to other: CGFloat, accuracy epsilon: CGFloat) -> Bool {
        return abs(self - other) <= epsilon
    }
}

extension CGAffineTransform {
    public func isEqual(to other: CGAffineTransform, accuracy epsilon: CGFloat) -> Bool {
        return (abs(a - other.a) <= epsilon) &&
            (abs(b - other.b) <= epsilon) &&
            (abs(c - other.c) <= epsilon) &&
            (abs(d - other.d) <= epsilon) &&
            (abs(tx - other.tx) <= epsilon) &&
            (abs(ty - other.ty) <= epsilon)
    }
}

extension UIImage {
    public func withOrientation(_ orientation: UIImage.Orientation) -> UIImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }

        return UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
    }
}

extension String {
    func width(withFont font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}
