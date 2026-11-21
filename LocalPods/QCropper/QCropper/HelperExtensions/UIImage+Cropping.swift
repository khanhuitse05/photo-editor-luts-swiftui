//
//  UIImage+Cropping.swift
//
//  Created by Chen Qizhi on 2019/10/15.
//

import UIKit

extension UIImage {
    public func cropped(withCropperState cropperState: CropperState) -> UIImage? {
        guard size.width > 1,
            size.height > 1,
            cropperState.viewFrame.width > 1,
            cropperState.viewFrame.height > 1 else {
            return self
        }

        var targetImage: UIImage? = self

        autoreleasepool {
            let orientation = UIImage.Orientation(rawValue: cropperState.imageOrientationRawValue) ?? .up
            guard let image = self.withOrientation(orientation) else {
                targetImage = self
                return
            }

            var transform: CGAffineTransform = .identity
            let translation = cropperState.photoTranslation

            let t = cropperState.imageViewTransform
            let xScale: CGFloat = sqrt(t.a * t.a + t.c * t.c)
            let yScale: CGFloat = sqrt(t.b * t.b + t.d * t.d)

            transform = transform.translatedBy(x: translation.x, y: translation.y)
                .rotated(by: cropperState.angle)
                .scaledBy(x: xScale, y: yScale)

            let cropSize = cropperState.cropBoxFrame.size
            let imageViewBoundsSize = cropperState.imageViewBoundsSize

            var outputWidth = cropSize.width * image.size.width / (imageViewBoundsSize.width * xScale)
            let maxWidth = Self.maxWidthForCropSize(cropSize)
            if outputWidth > maxWidth {
                outputWidth = maxWidth
            }

            if let cgImage = Self.newTransformedImage(transform,
                                                      sourceImage: image.cgImage,
                                                      sourceSize: image.size,
                                                      sourceOrientation: image.imageOrientation,
                                                      outputWidth: outputWidth,
                                                      cropSize: cropSize,
                                                      imageViewBoundsSize: imageViewBoundsSize) {
                targetImage = UIImage(cgImage: cgImage)
            }
        }

        return targetImage
    }

    private class func maxWidthForCropSize(_ cropSize: CGSize) -> CGFloat {
        var maxWidth = QCropper.Config.croppingImageShortSideMaxSize
        if cropSize.width > cropSize.height {
            maxWidth = QCropper.Config.croppingImageShortSideMaxSize * cropSize.width / cropSize.height
            if maxWidth > QCropper.Config.croppingImageLongSideMaxSize {
                maxWidth = QCropper.Config.croppingImageLongSideMaxSize
            }
        } else {
            maxWidth = QCropper.Config.croppingImageShortSideMaxSize
            let height = maxWidth * cropSize.height / cropSize.width
            if height > QCropper.Config.croppingImageLongSideMaxSize {
                maxWidth = QCropper.Config.croppingImageLongSideMaxSize * cropSize.width / cropSize.height
            }
        }
        return maxWidth
    }

    private class func bitmapInfoForRedraw(_ sourceAlphaInfo: CGImageAlphaInfo) -> UInt32 {
        var targetAlphaInfo: CGImageAlphaInfo = sourceAlphaInfo

        if sourceAlphaInfo == .none || sourceAlphaInfo == .alphaOnly {
            targetAlphaInfo = .noneSkipFirst
        } else if sourceAlphaInfo == .first {
            targetAlphaInfo = .premultipliedFirst
        } else if sourceAlphaInfo == .last {
            targetAlphaInfo = .premultipliedLast
        }

        // should be targetAlphaInfo + kCGBitmapByteOrderDefault(== 0)
        return targetAlphaInfo.rawValue
    }

    private class func newScaledImage(_ originalSource: CGImage?, with orientation: UIImage.Orientation, to size: CGSize, with quality: CGInterpolationQuality) -> CGImage? {
        guard let source = originalSource,
              let colorSpace = source.colorSpace,
              let context = CGContext(data: nil,
                                      width: Int(size.width),
                                      height: Int(size.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: colorSpace,
                                      bitmapInfo: Self.bitmapInfoForRedraw(source.alphaInfo))
        else {
            return originalSource
        }

        var srcSize = size
        var rotation: CGFloat = 0.0

        switch orientation {
        case .up:
            rotation = 0
        case .down:
            rotation = .pi
        case .left:
            rotation = CGFloat.pi / 2.0
            srcSize = CGSize(width: size.height, height: size.width)
        case .right:
            rotation = -CGFloat.pi / 2.0
            srcSize = CGSize(width: size.height, height: size.width)
        default:
            break
        }

        context.clear(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        context.interpolationQuality = quality
        context.translateBy(x: size.width / 2, y: size.height / 2)
        context.rotate(by: rotation)
        context.setShouldAntialias(false)

        if orientation == .upMirrored {
            context.scaleBy(x: -1.0, y: 1.0)
        }
        context.draw(source, in: CGRect(x: -srcSize.width / 2, y: -srcSize.height / 2, width: srcSize.width, height: srcSize.height))

        return context.makeImage()
    }

    private class func newTransformedImage(_ transform: CGAffineTransform,
                                           sourceImage: CGImage?,
                                           sourceSize: CGSize,
                                           sourceOrientation: UIImage.Orientation,
                                           outputWidth: CGFloat,
                                           cropSize: CGSize,
                                           imageViewBoundsSize: CGSize) -> CGImage? {
        var sourceScaled: CGImage?

        autoreleasepool {
            sourceScaled = self.newScaledImage(sourceImage, with: sourceOrientation, to: sourceSize, with: CGInterpolationQuality.none)
        }

        let aspect = cropSize.height / cropSize.width
        let outputSize = CGSize(width: outputWidth, height: outputWidth * aspect)

        guard let source = sourceScaled,
            let colorSpace = source.colorSpace,
            let context = CGContext(data: nil,
                                    width: Int(outputSize.width),
                                    height: Int(outputSize.height),
                                    bitsPerComponent: 8,
                                    bytesPerRow: 0,
                                    space: colorSpace,
                                    bitmapInfo: Self.bitmapInfoForRedraw(source.alphaInfo)) else {
            return sourceScaled
        }

        context.clear(CGRect(x: 0, y: 0, width: outputSize.width, height: outputSize.height))
        context.setShouldAntialias(false)
        context.interpolationQuality = CGInterpolationQuality.none

        var uiCoords = CGAffineTransform(scaleX: outputSize.width / cropSize.width, y: outputSize.height / cropSize.height)
        uiCoords = uiCoords.translatedBy(x: cropSize.width / 2.0, y: cropSize.height / 2.0)
        uiCoords = uiCoords.scaledBy(x: 1.0, y: -1.0)
        context.concatenate(uiCoords)

        context.concatenate(transform)
        context.scaleBy(x: 1.0, y: -1.0)

        context.draw(source, in: CGRect(x: -imageViewBoundsSize.width / 2.0, y: -imageViewBoundsSize.height / 2.0, width: imageViewBoundsSize.width, height: imageViewBoundsSize.height))

        return context.makeImage()
    }
}
