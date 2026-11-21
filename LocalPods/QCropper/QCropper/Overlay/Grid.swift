//
//  Grid.swift
//
//  Created by Chen Qizhi on 2019/10/15.
//

import UIKit

// extension Overlay.CropBox {
class Grid: UIView {

    public var horizontalLinesCount: UInt = 2 {
        didSet {
            setNeedsDisplay()
        }
    }

    public var verticalLinesCount: UInt = 2 {
        didSet {
            setNeedsDisplay()
        }
    }

    public var lineColor: UIColor = UIColor(white: 1, alpha: 0.7) {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Defaults to one device pixel at the view's display scale.
    public var lineWidth: CGFloat? {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        context.setLineWidth(lineWidth ?? traitCollection.hairlineWidth)
        context.setStrokeColor(lineColor.cgColor)

        let horizontalLineSpacing = frame.size.width / CGFloat(horizontalLinesCount + 1)
        let verticalLineSpacing = frame.size.height / CGFloat(verticalLinesCount + 1)

        for i in 1 ..< horizontalLinesCount + 1 {
            context.move(to: CGPoint(x: CGFloat(i) * horizontalLineSpacing, y: 0))
            context.addLine(to: CGPoint(x: CGFloat(i) * horizontalLineSpacing, y: frame.size.height))
        }

        for i in 1 ..< verticalLinesCount + 1 {
            context.move(to: CGPoint(x: 0, y: CGFloat(i) * verticalLineSpacing))
            context.addLine(to: CGPoint(x: frame.size.width, y: CGFloat(i) * verticalLineSpacing))
        }

        context.strokePath()
    }
}
