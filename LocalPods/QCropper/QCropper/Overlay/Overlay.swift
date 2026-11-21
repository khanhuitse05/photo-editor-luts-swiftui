//
//  Overlay.swift
//
//  Created by Chen Qizhi on 2019/10/15.
//

import UIKit

/// All overlays, including grid, crop box, translucent blur mask
open class Overlay: UIView {

    public var cropBoxAlpha: CGFloat {
        get {
            return cropBox.alpha
        }
        set {
            cropBox.alpha = newValue
        }
    }

    public var gridLinesAlpha: CGFloat {
        get {
            return cropBox.gridLinesAlpha
        }
        set {
            cropBox.gridLinesAlpha = newValue
        }
    }

    public var gridLinesCount: UInt = 2 {
        didSet {
            cropBox.gridLinesView.horizontalLinesCount = gridLinesCount
            cropBox.gridLinesView.verticalLinesCount = gridLinesCount
        }
    }

    public var isCircular: Bool = false

    public var isBlurEnabled: Bool = true

    public var blur: Bool = true {
        didSet {
            if blur, isBlurEnabled {
                translucentMaskView.effect = UIBlurEffect(style: .dark)
                translucentMaskView.backgroundColor = .clear
            } else {
                translucentMaskView.effect = nil
                translucentMaskView.backgroundColor = maskColor
            }
        }
    }

    // Take effect when blur = false
    public var maskColor: UIColor = UIColor(white: 0.1, alpha: 0.3) {
        didSet {
            if !blur || !isBlurEnabled {
                translucentMaskView.backgroundColor = maskColor
            }
        }
    }

    public var free: Bool = true {
        didSet {
            if free {
                cropBox.layer.borderWidth = 1
            } else {
                cropBox.layer.borderWidth = 2
            }
        }
    }

    public var cropBoxFrame: CGRect {
        get {
            return cropBox.frame
        }
        set(frame) {
            cropBox.frame = frame
            updateMask(animated: false)
        }
    }

    open func setCropBoxFrame(_ cropBoxFrame: CGRect, blurLayerAnimated: Bool) {
        cropBox.frame = cropBoxFrame
        updateMask(animated: blurLayerAnimated)
    }

    public var cropBox = CropBox(frame: .zero)

    public lazy var translucentMaskView: UIVisualEffectView = {
        let vev = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        vev.backgroundColor = .clear
        vev.frame = self.bounds
        vev.isUserInteractionEnabled = false
        vev.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleHeight, .flexibleWidth]
        return vev
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        clipsToBounds = true
        isUserInteractionEnabled = false

        addSubview(translucentMaskView)
        addSubview(cropBox)

        gridLinesAlpha = 0
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func updateMask(animated: Bool) {

        if isCircular {
            cropBox.layer.cornerRadius = min(cropBox.width, cropBox.height) / 2
            cropBox.layer.masksToBounds = true
        } else {
            cropBox.layer.cornerRadius = 0
            cropBox.layer.masksToBounds = false
        }

        var maskLayer: CAShapeLayer
        if let ml = translucentMaskView.layer.mask as? CAShapeLayer {
            maskLayer = ml
        } else {
            maskLayer = CAShapeLayer()
            translucentMaskView.layer.mask = maskLayer
        }

        let bezierPath = UIBezierPath(rect: translucentMaskView.bounds)
        if isCircular {
            let center = UIBezierPath(roundedRect: cropBox.frame, cornerRadius: min(cropBox.width, cropBox.height) / 2)
            bezierPath.append(center)
        } else {
            print(cropBox.frame)
            let center = UIBezierPath(rect: cropBox.frame)
            bezierPath.append(center)
        }

        maskLayer.fillRule = .evenOdd
        bezierPath.usesEvenOddFillRule = true

        if animated {
            let animation = CABasicAnimation(keyPath: "path")
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            maskLayer.path = bezierPath.cgPath
            animation.duration = 0.25
            maskLayer.add(animation, forKey: animation.keyPath)
        } else {
            maskLayer.path = bezierPath.cgPath
        }
    }
}
