//
//  StateRestorable.swift
//
//  Created by Chen Qizhi on 2019/10/18.
//

import UIKit

public protocol StateRestorable {
    func isCurrentlyInState(_ state: CropperState?) -> Bool
    func saveState() -> CropperState
    func restoreState(_ state: CropperState, animated: Bool)
}

extension StateRestorable where Self: CropperViewController {
    public func isCurrentlyInState(_ state: CropperState?) -> Bool {
        guard let state = state else { return false }
        let epsilon: CGFloat = 0.0001

        if state.viewFrame.isEqual(to: view.frame, accuracy: epsilon),
            state.angle.isEqual(to: totalAngle, accuracy: epsilon),
            state.rotationAngle.isEqual(to: rotationAngle, accuracy: epsilon),
            state.straightenAngle.isEqual(to: straightenAngle, accuracy: epsilon),
            state.flipAngle.isEqual(to: flipAngle, accuracy: epsilon),
            state.imageOrientationRawValue == imageView.image?.imageOrientation.rawValue ?? 0,
            state.scrollViewTransform.isEqual(to: scrollView.transform, accuracy: epsilon),
            state.scrollViewCenter.isEqual(to: scrollView.center, accuracy: epsilon),
            state.scrollViewBounds.isEqual(to: scrollView.bounds, accuracy: epsilon),
            state.scrollViewContentOffset.isEqual(to: scrollView.contentOffset, accuracy: epsilon),
            state.scrollViewMinimumZoomScale.isEqual(to: scrollView.minimumZoomScale, accuracy: epsilon),
            state.scrollViewMaximumZoomScale.isEqual(to: scrollView.maximumZoomScale, accuracy: epsilon),
            state.scrollViewZoomScale.isEqual(to: scrollView.zoomScale, accuracy: epsilon),
            state.cropBoxFrame.isEqual(to: overlay.cropBoxFrame, accuracy: epsilon) {
            return true
        }

        return false
    }

    public func saveState() -> CropperState {
        let cs = CropperState(viewFrame: view.frame,
                              angle: totalAngle,
                              rotationAngle: rotationAngle,
                              straightenAngle: straightenAngle,
                              flipAngle: flipAngle,
                              imageOrientationRawValue: imageView.image?.imageOrientation.rawValue ?? 0,
                              scrollViewTransform: scrollView.transform,
                              scrollViewCenter: scrollView.center,
                              scrollViewBounds: scrollView.bounds,
                              scrollViewContentOffset: scrollView.contentOffset,
                              scrollViewMinimumZoomScale: scrollView.minimumZoomScale,
                              scrollViewMaximumZoomScale: scrollView.maximumZoomScale,
                              scrollViewZoomScale: scrollView.zoomScale,
                              cropBoxFrame: overlay.cropBoxFrame,
                              photoTranslation: photoTranslation(),
                              imageViewTransform: imageView.transform,
                              imageViewBoundsSize: imageView.bounds.size)
        return cs
    }

    public func restoreState(_ state: CropperState, animated: Bool = false) {
        guard view.frame.equalTo(state.viewFrame) else {
            return
        }

        let animationsBlock = { () -> Void in
            self.rotationAngle = state.rotationAngle
            self.straightenAngle = state.straightenAngle
            self.flipAngle = state.flipAngle
            let orientation = UIImage.Orientation(rawValue: state.imageOrientationRawValue) ?? .up
            self.imageView.image = self.imageView.image?.withOrientation(orientation)
            self.scrollView.minimumZoomScale = state.scrollViewMinimumZoomScale
            self.scrollView.maximumZoomScale = state.scrollViewMaximumZoomScale
            self.scrollView.zoomScale = state.scrollViewZoomScale
            self.scrollView.transform = state.scrollViewTransform
            self.scrollView.bounds = state.scrollViewBounds
            self.scrollView.contentOffset = state.scrollViewContentOffset
            self.scrollView.center = state.scrollViewCenter
            self.overlay.cropBoxFrame = state.cropBoxFrame
            if self.overlay.cropBoxFrame.size.width > self.overlay.cropBoxFrame.size.height {
                self.aspectRatioPicker.aspectRatios = self.verticalAspectRatios
            } else {
                self.aspectRatioPicker.aspectRatios = self.verticalAspectRatios.map { $0.rotated }
            }
            self.aspectRatioPicker.rotated = false
            self.aspectRatioPicker.selectedAspectRatio = .freeForm
            self.angleRuler.value = state.straightenAngle * 180 / CGFloat.pi
            // No need restore
            //            self.currentAspectRatioValue = state.currentAspectRatioValue
            //            self.photoTranslation() = state.photoTranslation
            //            self.imageView.transform = state.imageViewTransform
            //            self.imageView.bounds.size = state.imageViewBoundsSize
        }

        if animated {
            UIView.animate(withDuration: 0.25, animations: animationsBlock)
        } else {
            animationsBlock()
        }
    }
}
