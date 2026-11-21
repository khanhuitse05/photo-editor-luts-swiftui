//
//  CropBox.swift
//
//  Created by Chen Qizhi on 2019/10/15.
//

import UIKit

// extension Overlay {
open class CropBox: UIView {

    var gridLinesAlpha: CGFloat = 0 {
        didSet {
            gridLinesView.alpha = gridLinesAlpha
        }
    }

    var borderWidth: CGFloat = 1 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    lazy var gridLinesView: Grid = {
        let view = Grid(frame: bounds)
        view.backgroundColor = UIColor.clear
        view.alpha = 0
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleBottomMargin, .flexibleBottomMargin, .flexibleRightMargin]
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        clipsToBounds = false
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        autoresizingMask = UIView.AutoresizingMask(rawValue: 0)
        addSubview(gridLinesView)

        setupCorners()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        gridLinesView.frame = bounds
        gridLinesView.setNeedsDisplay()
    }

    func setupCorners() {
        let offset: CGFloat = -1

        let topLeft = CornerView(.topLeft)
        topLeft.center = CGPoint(x: offset, y: offset)
        topLeft.autoresizingMask = UIView.AutoresizingMask(rawValue: 0)
        addSubview(topLeft)

        let topRight = CornerView(.topRight)
        topRight.center = CGPoint(x: frame.size.width - offset, y: offset)
        topRight.autoresizingMask = .flexibleLeftMargin
        addSubview(topRight)

        let bottomRight = CornerView(.bottomRight)
        bottomRight.center = CGPoint(x: frame.size.width - offset, y: frame.size.height - offset)
        bottomRight.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
        addSubview(bottomRight)

        let bottomLeft = CornerView(.bottomLeft)
        bottomLeft.center = CGPoint(x: offset, y: frame.size.height - offset)
        bottomLeft.autoresizingMask = .flexibleTopMargin
        addSubview(bottomLeft)
    }
}

// MARK: CornerType

extension CropBox {
    enum CornerType {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
}

// MARK: CornerView

extension CropBox {
    class CornerView: UIView {

        let cornerSize: CGFloat = 20

        private let type: CornerType
        private let horizontal = UIView()
        private let vertical = UIView()

        init(_ type: CornerType) {
            self.type = type
            super.init(frame: CGRect(x: 0, y: 0, width: cornerSize, height: cornerSize))

            backgroundColor = UIColor.clear

            let lineColor: UIColor = .white

            horizontal.backgroundColor = lineColor
            addSubview(horizontal)

            vertical.backgroundColor = lineColor
            addSubview(vertical)

            layoutLines()

            // Line thickness includes one device pixel; lay the lines out again when the display scale changes.
            registerForTraitChanges([UITraitDisplayScale.self]) { (self: Self, _) in
                self.layoutLines()
            }
        }

        private func layoutLines() {
            let lineWidth: CGFloat = 2 + traitCollection.hairlineWidth

            horizontal.frame = CGRect(x: 0, y: 0, width: cornerSize, height: lineWidth)
            vertical.frame = CGRect(x: 0, y: 0, width: lineWidth, height: cornerSize)

            let shortMid = lineWidth / 2 // mid of short side of line rect
            let longMid = cornerSize / 2 // mid of long side of line rect

            switch type {
            case .topLeft:
                horizontal.center = CGPoint(x: longMid, y: shortMid)
                vertical.center = CGPoint(x: shortMid, y: longMid)
                layer.anchorPoint = CGPoint(x: shortMid / cornerSize, y: shortMid / cornerSize)
            case .topRight:
                horizontal.center = CGPoint(x: longMid, y: shortMid)
                vertical.center = CGPoint(x: cornerSize - shortMid, y: longMid)
                layer.anchorPoint = CGPoint(x: 1 - shortMid / cornerSize, y: shortMid / cornerSize)
            case .bottomLeft:
                horizontal.center = CGPoint(x: longMid, y: cornerSize - shortMid)
                vertical.center = CGPoint(x: shortMid, y: longMid)
                layer.anchorPoint = CGPoint(x: shortMid / cornerSize, y: 1 - shortMid / cornerSize)
            case .bottomRight:
                horizontal.center = CGPoint(x: longMid, y: cornerSize - shortMid)
                vertical.center = CGPoint(x: cornerSize - shortMid, y: longMid)
                layer.anchorPoint = CGPoint(x: 1 - shortMid / cornerSize, y: 1 - shortMid / cornerSize)
            }
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
