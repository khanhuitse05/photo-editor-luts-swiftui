//
//  CropBoxEdgeDraggable.swift
//
//  Created by Chen Qizhi on 2019/10/18.
//

import UIKit

protocol CropBoxEdgeDraggable {
    func nearestCropBoxEdgeForPoint(point: CGPoint) -> CropBoxEdge
    func updateCropBoxFrameWithPanGesturePoint(_ point: CGPoint)
}

extension CropBoxEdgeDraggable where Self: CropperViewController {

    func nearestCropBoxEdgeForPoint(point: CGPoint) -> CropBoxEdge {
        var frame = overlay.cropBoxFrame

        frame = frame.insetBy(dx: -cropBoxHotArea / 2.0, dy: -cropBoxHotArea / 2.0)

        let topLeftRect = CGRect(origin: frame.origin, size: CGSize(width: cropBoxHotArea, height: cropBoxHotArea))

        if topLeftRect.contains(point) {
            return .topLeft
        }

        var topRightRect = topLeftRect
        topRightRect.origin.x = frame.maxX - cropBoxHotArea
        if topRightRect.contains(point) {
            return .topRight
        }

        var bottomLeftRect = topLeftRect
        bottomLeftRect.origin.y = frame.maxY - cropBoxHotArea
        if bottomLeftRect.contains(point) {
            return .bottomLeft
        }

        var bottomRightRect = topRightRect
        bottomRightRect.origin.y = bottomLeftRect.origin.y
        if bottomRightRect.contains(point) {
            return .bottomRight
        }

        let topRect = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: cropBoxHotArea))
        if topRect.contains(point) {
            return .top
        }

        var bottomRect = topRect
        bottomRect.origin.y = frame.maxY - cropBoxHotArea
        if bottomRect.contains(point) {
            return .bottom
        }

        let leftRect = CGRect(origin: frame.origin, size: CGSize(width: cropBoxHotArea, height: frame.height))
        if leftRect.contains(point) {
            return .left
        }

        var rightRect = leftRect
        rightRect.origin.x = frame.maxX - cropBoxHotArea
        if rightRect.contains(point) {
            return .right
        }

        return .none
    }

    func updateCropBoxFrameWithPanGesturePoint(_ point: CGPoint) {
        var point = point
        var frame = overlay.cropBoxFrame
        let originFrame = panBeginningCropBoxFrame
        let contentFrame = maxCropRegion

        point.x = max(contentFrame.origin.x, point.x)
        point.y = max(contentFrame.origin.y, point.y)

        // The delta between where we first tapped, and where our finger is now
        var xDelta = (point.x - panBeginningPoint.x)
        var yDelta = (point.y - panBeginningPoint.y)

        let aspectRatio = currentAspectRatioValue

        var panHorizontal: Bool = false
        var panVertical: Bool = false

        switch panBeginningCropBoxEdge {
        case .left:
            frame.origin.x = originFrame.origin.x + xDelta
            frame.size.width = max(cropBoxMinSize, originFrame.size.width - xDelta)
            if aspectRatioLocked {
                panHorizontal = true
                xDelta = max(xDelta, 0)
                let scaleOrigin = CGPoint(x: originFrame.maxX, y: originFrame.midY)
                frame.size.height = frame.size.width / aspectRatio
                frame.origin.y = scaleOrigin.y - (frame.size.height * 0.5)
            }

        case .right:
            if aspectRatioLocked {
                panHorizontal = true
                frame.size.width = max(cropBoxMinSize, originFrame.size.width + xDelta)
                frame.size.width = min(frame.size.width, contentFrame.size.height * aspectRatio)
                let scaleOrigin = CGPoint(x: originFrame.minX, y: originFrame.midY)
                frame.size.height = frame.size.width / aspectRatio
                frame.origin.y = scaleOrigin.y - (frame.size.height * 0.5)
            } else {
                frame.size.width = originFrame.size.width + xDelta
            }

        case .bottom:
            if aspectRatioLocked {
                panVertical = true
                frame.size.height = max(cropBoxMinSize, originFrame.size.height + yDelta)
                frame.size.height = min(frame.size.height, contentFrame.size.width / aspectRatio)
                let scaleOrigin = CGPoint(x: originFrame.midX, y: originFrame.minY)
                frame.size.width = frame.size.height * aspectRatio
                frame.origin.x = scaleOrigin.x - (frame.size.width * 0.5)
            } else {
                frame.size.height = originFrame.size.height + yDelta
            }

        case .top:
            if aspectRatioLocked {
                panVertical = true
                yDelta = max(0, yDelta)
                frame.origin.y = originFrame.origin.y + yDelta
                frame.size.height = max(cropBoxMinSize, originFrame.size.height - yDelta)
                let scaleOrigin = CGPoint(x: originFrame.midX, y: originFrame.maxY)
                frame.size.width = frame.size.height * aspectRatio
                frame.origin.x = scaleOrigin.x - (frame.size.width * 0.5)
            } else {
                frame.origin.y = originFrame.origin.y + yDelta
                frame.size.height = originFrame.size.height - yDelta
            }

        case .topLeft:
            if aspectRatioLocked {
                xDelta = max(xDelta, 0)
                yDelta = max(yDelta, 0)

                var distance = CGPoint()
                distance.x = 1.0 - (xDelta / originFrame.width)
                distance.y = 1.0 - (yDelta / originFrame.height)

                let scale = (distance.x + distance.y) * 0.5

                frame.size.width = (originFrame.width * scale)
                frame.size.height = (originFrame.height * scale)
                frame.origin.x = originFrame.origin.x + (originFrame.width - frame.size.width)
                frame.origin.y = originFrame.origin.y + (originFrame.height - frame.size.height)

                panVertical = true
                panHorizontal = true
            } else {
                frame.origin.x = originFrame.origin.x + xDelta
                frame.size.width = originFrame.size.width - xDelta
                frame.origin.y = originFrame.origin.y + yDelta
                frame.size.height = originFrame.size.height - yDelta
            }

        case .topRight:
            if aspectRatioLocked {
                xDelta = max(xDelta, 0)
                yDelta = max(yDelta, 0)

                var distance = CGPoint()
                distance.x = 1.0 - ((-xDelta) / originFrame.width)
                distance.y = 1.0 - (yDelta / originFrame.height)

                var scale = (distance.x + distance.y) * 0.5
                scale = min(1.0, scale)

                frame.size.width = (originFrame.width * scale)
                frame.size.height = (originFrame.height * scale)
                frame.origin.y = originFrame.maxY - frame.size.height

                panVertical = true
                panHorizontal = true
            } else {
                frame.size.width = originFrame.size.width + xDelta
                frame.origin.y = originFrame.origin.y + yDelta
                frame.size.height = originFrame.size.height - yDelta
            }

        case .bottomLeft:
            if aspectRatioLocked {
                var distance = CGPoint()
                distance.x = 1.0 - (xDelta / originFrame.width)
                distance.y = 1.0 - (-yDelta / originFrame.height)

                let scale = (distance.x + distance.y) * 0.5

                frame.size.width = (originFrame.width * scale)
                frame.size.height = (originFrame.height * scale)
                frame.origin.x = originFrame.maxX - frame.size.width

                panVertical = true
                panHorizontal = true
            } else {
                frame.size.height = originFrame.size.height + yDelta
                frame.origin.x = originFrame.origin.x + xDelta
                frame.size.width = originFrame.size.width - xDelta
            }

        case .bottomRight:
            if aspectRatioLocked {
                var distance = CGPoint()
                distance.x = 1.0 - ((-1 * xDelta) / originFrame.width)
                distance.y = 1.0 - ((-1 * yDelta) / originFrame.height)

                let scale = (distance.x + distance.y) * 0.5

                frame.size.width = (originFrame.width * scale)
                frame.size.height = (originFrame.height * scale)

                panVertical = true
                panHorizontal = true
            } else {
                frame.size.height = originFrame.size.height + yDelta
                frame.size.width = originFrame.size.width + xDelta
            }

        case .none:
            break
        }

        // Work out the limits the box may be scaled before it starts to overlap itself
        var minSize: CGSize = .zero
        minSize.width = cropBoxMinSize
        minSize.height = cropBoxMinSize

        var maxSize: CGSize = .zero
        maxSize.width = contentFrame.width
        maxSize.height = contentFrame.height

        // clamp the box to ensure it doesn't go beyond the bounds we've set
        if aspectRatioLocked, panHorizontal {
            maxSize.height = contentFrame.size.width / aspectRatio
            if aspectRatio > 1 {
                minSize.width = cropBoxMinSize * aspectRatio
            } else {
                minSize.height = cropBoxMinSize / aspectRatio
            }
        }

        if aspectRatioLocked, panVertical {
            maxSize.width = contentFrame.size.height * aspectRatio
            if aspectRatio > 1 {
                minSize.width = cropBoxMinSize * aspectRatio
            } else {
                minSize.height = cropBoxMinSize / aspectRatio
            }
        }

        // Clamp the minimum size
        frame.size.width = max(frame.size.width, minSize.width)
        frame.size.height = max(frame.size.height, minSize.height)

        // Clamp the maximum size
        frame.size.width = min(frame.size.width, maxSize.width)
        frame.size.height = min(frame.size.height, maxSize.height)

        frame.origin.x = max(frame.origin.x, contentFrame.minX)
        frame.origin.x = min(frame.origin.x, contentFrame.maxX - minSize.width)
        frame.origin.x = min(frame.origin.x, originFrame.maxX - minSize.width) // Cannot pan the left side of the box out of the right area of the previous box

        frame.origin.y = max(frame.origin.y, contentFrame.minY)
        frame.origin.y = min(frame.origin.y, contentFrame.maxY - minSize.height)
        frame.origin.y = min(frame.origin.y, originFrame.maxY - minSize.height) // Cannot pan the top of the box out of the bottom area of the previous frame

        cropBoxFrame = frame
    }
}
