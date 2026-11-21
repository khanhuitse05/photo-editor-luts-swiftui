//
//  AspectRatioSettable.swift
//
//  Created by Chen Qizhi on 2019/10/18.
//

import UIKit

public protocol AspectRatioSettable {
    func setAspectRatio(_ aspectRatio: AspectRatio)
    func setAspectRatioValue(_ aspectRatioValue: CGFloat)
}

extension AspectRatioSettable where Self: CropperViewController {
    public func setAspectRatio(_ aspectRatio: AspectRatio) {
        switch aspectRatio {
        case .original:
            var width: CGFloat
            var height: CGFloat
            let angle = standardizeAngle(rotationAngle)
            if angle.isEqual(to: .pi / 2.0, accuracy: 0.001) ||
                angle.isEqual(to: .pi * 1.5, accuracy: 0.001) {
                width = originalImage.size.height
                height = originalImage.size.width
            } else {
                width = originalImage.size.width
                height = originalImage.size.height
            }

            if aspectRatioPicker.rotated {
                swap(&width, &height)
            }

            if width > height {
                aspectRatioPicker.selectedBox = .horizontal
            } else if width < height {
                aspectRatioPicker.selectedBox = .vertical
            } else {
                aspectRatioPicker.selectedBox = .none
            }
            setAspectRatioValue(width / height)
            aspectRatioLocked = true
        case .freeForm:
            aspectRatioPicker.selectedBox = .none
            aspectRatioLocked = false
        case .square:
            aspectRatioPicker.selectedBox = .none
            setAspectRatioValue(1)
            aspectRatioLocked = true
        case let .ratio(width, height):
            if width > height {
                aspectRatioPicker.selectedBox = .horizontal
            } else if width < height {
                aspectRatioPicker.selectedBox = .vertical
            } else {
                aspectRatioPicker.selectedBox = .none
            }
            setAspectRatioValue(CGFloat(width) / CGFloat(height))
            aspectRatioLocked = true
        }
    }

    public func setAspectRatioValue(_ aspectRatioValue: CGFloat) {
        guard aspectRatioValue > 0 else { return }

        topBar.isUserInteractionEnabled = false
        bottomView.isUserInteractionEnabled = false
        aspectRatioLocked = true
        currentAspectRatioValue = aspectRatioValue

        var targetCropBoxFrame: CGRect
        let height: CGFloat = maxCropRegion.size.width / aspectRatioValue
        if height <= maxCropRegion.size.height {
            targetCropBoxFrame = CGRect(center: defaultCropBoxCenter, size: CGSize(width: maxCropRegion.size.width, height: height))
        } else {
            let width = maxCropRegion.size.height * aspectRatioValue
            targetCropBoxFrame = CGRect(center: defaultCropBoxCenter, size: CGSize(width: width, height: maxCropRegion.size.height))
        }
        targetCropBoxFrame = safeCropBoxFrame(targetCropBoxFrame)

        let currentCropBoxFrame = overlay.cropBoxFrame

        /// The content of the image is getting bigger and bigger when switching the aspect ratio.
        /// Make a fake cropBoxFrame to help calculate how much the image should be scaled.
        var contentBiggerThanCurrentTargetCropBoxFrame: CGRect
        if currentCropBoxFrame.size.width / currentCropBoxFrame.size.height > aspectRatioValue {
            contentBiggerThanCurrentTargetCropBoxFrame = CGRect(center: defaultCropBoxCenter, size: CGSize(width: currentCropBoxFrame.size.width, height: currentCropBoxFrame.size.width / aspectRatioValue))
        } else {
            contentBiggerThanCurrentTargetCropBoxFrame = CGRect(center: defaultCropBoxCenter, size: CGSize(width: currentCropBoxFrame.size.height * aspectRatioValue, height: currentCropBoxFrame.size.height))
        }
        let extraZoomScale = max(targetCropBoxFrame.size.width / contentBiggerThanCurrentTargetCropBoxFrame.size.width, targetCropBoxFrame.size.height / contentBiggerThanCurrentTargetCropBoxFrame.size.height)

        overlay.gridLinesAlpha = 0

        matchScrollViewAndCropView(animated: true, targetCropBoxFrame: targetCropBoxFrame, extraZoomScale: extraZoomScale, blurLayerAnimated: true, animations: nil, completion: {
            self.topBar.isUserInteractionEnabled = true
            self.bottomView.isUserInteractionEnabled = true
            self.updateButtons()
        })
    }
}
