//
//  AngleRuler.swift
//
//  Created by Chen Qizhi on 2019/10/15.
//

import UIKit

/// Will send 2 actions: valueChanged and editingDidEnd
public class AngleRuler: UIControl {
    /// Should be an integer multiple of numberOfGroupedScales
    var numberOfTotalScales: Int = 40
    var numberOfGroupedScales: Int = 10
    var scaleSpacing: CGFloat = 9

    var minimumValue: CGFloat = -45
    var maximumValue: CGFloat = 45
    var _value: CGFloat = 0 {
        didSet {
            if abs(_value) < 0.01 {
                zeroDot.isHidden = true
            } else {
                zeroDot.isHidden = false
            }
        }
    }

    var value: CGFloat {
        get {
            return _value
        }
        set {
            setValue(newValue, sendEvent: false)
        }
    }

    func setValue(_ newValue: CGFloat, sendEvent: Bool) {
        _value = newValue
        valueLabel.text = String(format: "%0.f", newValue)
        let x = CGFloat(numberOfTotalScales) * scaleSpacing * (newValue - minimumValue) / (maximumValue - minimumValue)
        if sendEvent {
            scrollView.contentOffset = CGPoint(x: x, y: 0)
        } else {
            scrollView.delegate = nil
            scrollView.contentOffset = CGPoint(x: x, y: 0)
            scrollView.delegate = self
        }
    }

    private let lineName = "line"
    private let margin: CGFloat = 15
    private let bottomMargin: CGFloat = 10
    private var borderWidth: CGFloat {
        return traitCollection.hairlineWidth
    }
    // Make pixel alignment to avoid anti-aliasing, 0.5 = lineWidth / 2
    private var pixelOffset: CGFloat {
        return borderWidth > 0 ? CGFloat(0.5.truncatingRemainder(dividingBy: Double(borderWidth))) : 0
    }
    private lazy var scrollViewContentInset = scrollView.frame.size.width / 2.0

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: self.bounds.insetBy(dx: margin, dy: 0))
        sv.backgroundColor = .clear
        sv.decelerationRate = .fast
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.delegate = self
        return sv
    }()

    lazy var valueLabel: UILabel = {
        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 20)))
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.center = CGPoint(x: self.midScaleLine.center.x, y: self.midScaleLine.frame.origin.y - 18)
        return label
    }()

    private lazy var midScaleLine: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 30))
        view.backgroundColor = .white
        view.center = CGPoint(x: self.frame.size.width / 2.0 + pixelOffset, y: self.frame.size.height - bottomMargin - 15)
        return view
    }()

    private lazy var midScaleLineBorder: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1 + 2 * borderWidth, height: 30 + 2 * borderWidth))
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        view.center = self.midScaleLine.center
        return view
    }()

    private lazy var zeroDot: UIView = {
        let x = (CGFloat(numberOfTotalScales) / 2) * scaleSpacing + pixelOffset + scrollViewContentInset - 3
        let view = UIView(frame: CGRect(x: x, y: frame.size.height - bottomMargin - 29, width: 6, height: 6))
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()

    private lazy var maskLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        let clear = UIColor.clear.cgColor
        let black = UIColor.black.cgColor
        layer.colors = [clear, black, black, clear]
        layer.locations = [0, 0.08, 0.92, 1]
        layer.frame = self.bounds
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()

    private func setupScaleLayers() {
        scrollView.layer.sublayers?.forEach { layer in
            if layer.name == lineName {
                layer.removeFromSuperlayer()
            }
        }

        func createShapeLayer() -> CAShapeLayer {
            let layer = CAShapeLayer()
            layer.name = lineName
            layer.lineWidth = 1
            layer.fillColor = UIColor.clear.cgColor
            return layer
        }

        let grayScales = createShapeLayer()
        grayScales.strokeColor = UIColor(white: 0.76, alpha: 1).cgColor
        let grayPath = CGMutablePath()

        let whiteScales = createShapeLayer()
        whiteScales.strokeColor = UIColor(white: 1, alpha: 1).cgColor
        let whitePath = CGMutablePath()

        let scaleBorders = createShapeLayer()
        scaleBorders.strokeColor = UIColor(white: 0, alpha: 0.2).cgColor
        scaleBorders.lineWidth = 1 + 2 * borderWidth
        let borderPath = CGMutablePath()

        let lineHeight: CGFloat = 10
        let lineBottom = frame.size.height - bottomMargin
        let lineTop = lineBottom - lineHeight

        for i in 0 ... numberOfTotalScales {
            let x = CGFloat(i) * scaleSpacing + pixelOffset + scrollViewContentInset

            if i % numberOfGroupedScales == 0 {
                whitePath.move(to: CGPoint(x: x, y: lineTop))
                whitePath.addLine(to: CGPoint(x: x, y: lineBottom))
            } else {
                grayPath.move(to: CGPoint(x: x, y: lineTop))
                grayPath.addLine(to: CGPoint(x: x, y: lineBottom))
            }

            borderPath.move(to: CGPoint(x: x, y: lineTop - borderWidth))
            borderPath.addLine(to: CGPoint(x: x, y: lineBottom + borderWidth))
        }

        grayScales.path = grayPath
        whiteScales.path = whitePath
        scaleBorders.path = borderPath
        scrollView.layer.addSublayer(scaleBorders)
        scrollView.layer.addSublayer(whiteScales)
        scrollView.layer.addSublayer(grayScales)

        scrollView.contentSize = CGSize(width: CGFloat(numberOfTotalScales) * scaleSpacing + 2 * scrollViewContentInset,
                                        height: scrollView.bounds.size.height)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        setupScaleLayers()
        scrollView.addSubview(zeroDot)
        addSubview(scrollView)
        addSubview(midScaleLineBorder)
        addSubview(midScaleLine)
        addSubview(valueLabel)
        layer.mask = maskLayer

        setValue(0, sendEvent: false)

        // Scale lines are pixel-aligned for the current display scale; realign them when it changes.
        registerForTraitChanges([UITraitDisplayScale.self]) { (self: Self, _) in
            let currentValue = self.value
            // Rebuilding the scale must not report a new angle.
            self.scrollView.delegate = nil
            self.updatePixelAlignment()
            self.setValue(currentValue, sendEvent: false) // Also reattaches the delegate.
        }
    }

    private var laidOutSize: CGSize = .zero

    public override func layoutSubviews() {
        super.layoutSubviews()

        // The ruler is built from its initial size; rebuild it when the window resize changes that size.
        guard !bounds.size.equalTo(laidOutSize) else { return }
        laidOutSize = bounds.size

        let currentValue = value
        // Resizing the scroll view moves its content offset; that must not report a new angle.
        scrollView.delegate = nil
        scrollView.frame = bounds.insetBy(dx: margin, dy: 0)
        scrollViewContentInset = scrollView.frame.size.width / 2.0
        maskLayer.frame = bounds
        updatePixelAlignment()
        valueLabel.center = CGPoint(x: midScaleLine.center.x, y: midScaleLine.frame.origin.y - 18)
        setValue(currentValue, sendEvent: false) // Also reattaches the delegate.
    }

    private func updatePixelAlignment() {
        setupScaleLayers()
        midScaleLine.center = CGPoint(x: frame.size.width / 2.0 + pixelOffset, y: frame.size.height - bottomMargin - 15)
        midScaleLineBorder.bounds.size = CGSize(width: 1 + 2 * borderWidth, height: 30 + 2 * borderWidth)
        midScaleLineBorder.center = midScaleLine.center
        zeroDot.frame.origin.x = (CGFloat(numberOfTotalScales) / 2) * scaleSpacing + pixelOffset + scrollViewContentInset - 3
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        if view == self {
            return scrollView
        }

        return view
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func autoZeroValue() {
        if abs(value) < 1 {
            UIView.animate(withDuration: 0.15) {
                self.setValue(0, sendEvent: true)
            }
        }
    }

    private func scrollEnded() {
        midScaleLine.backgroundColor = .white
        autoZeroValue()
        sendActions(for: .editingDidEnd)
    }
}

extension AngleRuler: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var value = scrollView.contentOffset.x * (maximumValue - minimumValue) / (CGFloat(numberOfTotalScales) * scaleSpacing) + minimumValue
        if value < minimumValue {
            value = minimumValue
        }
        if value > maximumValue {
            value = maximumValue
        }
        _value = value
        valueLabel.text = String(format: "%0.f", value)
        midScaleLine.backgroundColor = QCropper.Config.highlightColor
        sendActions(for: .valueChanged)
    }

    public func scrollViewDidEndDragging(_: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollEnded()
        }
    }

    public func scrollViewDidEndDecelerating(_: UIScrollView) {
        scrollEnded()
    }

    public func scrollViewDidEndScrollingAnimation(_: UIScrollView) {
        scrollEnded()
    }
}
