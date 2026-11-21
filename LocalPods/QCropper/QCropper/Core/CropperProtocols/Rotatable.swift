//
//  Rotatable.swift
//
//  Created by Chen Qizhi on 2019/10/18.
//

import UIKit

public protocol Rotatable {
    func setStraightenAngle(_ angle: CGFloat)
    func rotate90degrees(clockwise: Bool)
}

extension Rotatable where Self: CropperViewController {
    public func setStraightenAngle(_ angle: CGFloat) {
        overlay.cropBoxFrame = overlay.cropBoxFrame
        overlay.gridLinesAlpha = 1
        overlay.gridLinesCount = 8

        UIView.animate(withDuration: 0.2, animations: {
            self.overlay.blur = false
        })

        straightenAngle = angle
        scrollView.transform = CGAffineTransform(rotationAngle: totalAngle)

        let rect = overlay.cropBoxFrame
        let rotatedRect = rect.applying(CGAffineTransform(rotationAngle: totalAngle))
        let width = rotatedRect.size.width
        let height = rotatedRect.size.height
        let center = scrollView.center

        let contentOffset = scrollView.contentOffset
        let contentOffsetCenter = CGPoint(x: contentOffset.x + scrollView.bounds.size.width / 2, y: contentOffset.y + scrollView.bounds.size.height / 2)
        scrollView.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        let newContentOffset = CGPoint(x: contentOffsetCenter.x - scrollView.bounds.size.width / 2, y: contentOffsetCenter.y - scrollView.bounds.size.height / 2)
        scrollView.contentOffset = newContentOffset
        scrollView.center = center

        let shouldScale: Bool = scrollView.contentSize.width / scrollView.bounds.size.width <= 1.0 || scrollView.contentSize.height / scrollView.bounds.size.height <= 1.0
        if !manualZoomed || shouldScale {
            scrollView.minimumZoomScale = scrollViewZoomScaleToBounds()
            scrollView.setZoomScale(scrollViewZoomScaleToBounds(), animated: false)

            manualZoomed = false
        }

        scrollView.contentOffset = safeContentOffsetForScrollView(newContentOffset)
        updateButtons()
    }

    public func rotate90degrees(clockwise: Bool = true) {
        topBar.isUserInteractionEnabled = false
        bottomView.isUserInteractionEnabled = false

        guard let animationContainer = scrollView.superview else { return }

        // Make sure to cover the entire screen while rotating
        let scale = max(maxCropRegion.size.width / overlay.cropBoxFrame.size.width, maxCropRegion.size.height / overlay.cropBoxFrame.size.height)
        let frame = animationContainer.bounds.insetBy(dx: -animationContainer.width * scale * 3, dy: -animationContainer.height * scale * 3)

        let rotatingOverlay = Overlay(frame: frame)
        rotatingOverlay.blur = false
        rotatingOverlay.maskColor = backgroundView.backgroundColor ?? .black
        rotatingOverlay.cropBoxAlpha = 0
        animationContainer.addSubview(rotatingOverlay)

        let rotatingCropBoxFrame = rotatingOverlay.convert(overlay.cropBoxFrame, from: backgroundView)
        rotatingOverlay.cropBoxFrame = rotatingCropBoxFrame
        rotatingOverlay.transform = .identity
        rotatingOverlay.layer.anchorPoint = CGPoint(x: rotatingCropBoxFrame.midX / rotatingOverlay.size.width,
                                                    y: rotatingCropBoxFrame.midY / rotatingOverlay.size.height)

        overlay.isHidden = true

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            // rotate scroll view
            if clockwise {
                self.rotationAngle += CGFloat.pi / 2.0
            } else {
                self.rotationAngle -= CGFloat.pi / 2.0
            }
            self.rotationAngle = self.standardizeAngle(self.rotationAngle)
            self.scrollView.transform = CGAffineTransform(rotationAngle: self.totalAngle)

            // position scroll view
            let scrollViewCenter = self.scrollView.center
            let cropBoxCenter = self.defaultCropBoxCenter
            let r = self.overlay.cropBoxFrame
            var rect: CGRect = .zero

            let scaleX = self.maxCropRegion.size.width / r.size.height
            let scaleY = self.maxCropRegion.size.height / r.size.width

            let scale = min(scaleX, scaleY)

            rect.size.width = r.size.height * scale
            rect.size.height = r.size.width * scale

            rect.origin.x = cropBoxCenter.x - rect.size.width / 2.0
            rect.origin.y = cropBoxCenter.y - rect.size.height / 2.0

            self.overlay.cropBoxFrame = rect

            rotatingOverlay.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0).scaledBy(x: scale, y: scale)
            rotatingOverlay.center = scrollViewCenter

            let rotatedRect = rect.applying(CGAffineTransform(rotationAngle: self.totalAngle))
            let width = rotatedRect.size.width
            let height = rotatedRect.size.height

            let contentOffset = self.scrollView.contentOffset
            let showingContentCenter = CGPoint(x: contentOffset.x + self.scrollView.bounds.size.width / 2, y: contentOffset.y + self.scrollView.bounds.size.height / 2)
            let showingContentNormalizedCenter = CGPoint(x: showingContentCenter.x / self.imageView.width, y: showingContentCenter.y / self.imageView.height)

            self.scrollView.bounds = CGRect(x: 0, y: 0, width: width, height: height)
            let zoomScale = self.scrollView.zoomScale * scale
            self.willSetScrollViewZoomScale(zoomScale)
            self.scrollView.zoomScale = zoomScale
            let newContentOffset = CGPoint(x: showingContentNormalizedCenter.x * self.imageView.width - self.scrollView.bounds.size.width * 0.5,
                                           y: showingContentNormalizedCenter.y * self.imageView.height - self.scrollView.bounds.size.height * 0.5)
            self.scrollView.contentOffset = self.safeContentOffsetForScrollView(newContentOffset)
            self.scrollView.center = scrollViewCenter
        }, completion: { _ in
            self.aspectRatioPicker.rotateAspectRatios()
            self.overlay.cropBoxAlpha = 0
            self.overlay.blur = true
            self.overlay.isHidden = false
            UIView.animate(withDuration: 0.25, animations: {
                rotatingOverlay.alpha = 0
                self.overlay.cropBoxAlpha = 1
            }, completion: { _ in
                rotatingOverlay.isHidden = true
                rotatingOverlay.removeFromSuperview()
                self.topBar.isUserInteractionEnabled = true
                self.bottomView.isUserInteractionEnabled = true
                self.updateButtons()
            })
        })
    }
}
