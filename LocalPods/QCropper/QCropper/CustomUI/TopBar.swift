//
//  TopBar.swift
//
//  Created by Chen Qizhi on 2019/10/15.
//

import UIKit

class TopBar: UIView {
    lazy var flipButton: UIButton = {
        let button = self.iconButton(iconName: "QCropper.flip.horizontal.fill")
        button.left = 0
        button.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        return button
    }()

    lazy var rotateButton: UIButton = {
        let button = self.iconButton(iconName: "QCropper.rotate.right.fill")
        button.left = self.flipButton.right
        button.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        return button
    }()

    lazy var aspectRationButton: UIButton = {
        let button = self.iconButton(iconName: "QCropper.aspectratio.fill")
        button.right = self.width
        button.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
        return button
    }()

    lazy var blurBackgroundView: UIVisualEffectView = {
        let vev = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        vev.alpha = 0.3
        vev.backgroundColor = .clear
        vev.frame = self.bounds
        vev.isUserInteractionEnabled = false
        vev.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleHeight, .flexibleWidth]
        return vev
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(blurBackgroundView)
        addSubview(flipButton)
        addSubview(rotateButton)
        addSubview(aspectRationButton)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Keep the buttons clear of side insets, such as a vertical status bar. Each edge has its own inset.
        flipButton.left = safeAreaInsets.left
        rotateButton.left = flipButton.right
        aspectRationButton.right = width - safeAreaInsets.right
    }

    func iconButton(iconName: String) -> UIButton {
        let button = IconButton(iconName)
        button.bottom = height
        return button
    }
}

class IconButton: UIButton {
    init(_ iconName: String) {
        super.init(frame: CGRect(center: .zero, size: CGSize(width: 44, height: 44)))

        let image = UIImage(named: iconName, in: QCropper.Config.resourceBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        setImage(image, for: .normal)
        tintColor = UIColor(white: 0.725, alpha: 1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                tintColor = QCropper.Config.highlightColor
            } else {
                tintColor = UIColor(white: 0.725, alpha: 1)
            }
        }
    }
}
