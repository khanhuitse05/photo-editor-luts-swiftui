//
//  CropperViewController.swift
//
//  Created by Chen Qizhi on 2019/10/15.
//

import UIKit

enum CropBoxEdge: Int {
    case none
    case left
    case topLeft
    case top
    case topRight
    case right
    case bottomRight
    case bottom
    case bottomLeft
}

public protocol CropperViewControllerDelegate: AnyObject {
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?)
    func cropperDidCancel(_ cropper: CropperViewController)
}

public extension CropperViewControllerDelegate {
    func cropperDidCancel(_ cropper: CropperViewController) {
        cropper.dismiss(animated: true, completion: nil)
    }
}

open class CropperViewController: UIViewController, Rotatable, StateRestorable, Flipable {
    public let originalImage: UIImage
    var initialState: CropperState?
    var isCircular: Bool

    public init(originalImage: UIImage, initialState: CropperState? = nil, isCircular: Bool = false) {
        self.originalImage = originalImage
        self.initialState = initialState
        self.isCircular = isCircular
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public weak var delegate: CropperViewControllerDelegate?

    // if self not init with a state, return false
    open var isCurrentlyInInitialState: Bool {
        isCurrentlyInState(initialState)
    }

    public var aspectRatioLocked: Bool = false {
        didSet {
            overlay.free = !aspectRatioLocked
        }
    }

    public var currentAspectRatioValue: CGFloat = 1.0
    public var isCropBoxPanEnabled: Bool = true
    public var cropContentInset: UIEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

    let cropBoxHotArea: CGFloat = 50
    let cropBoxMinSize: CGFloat = 20
    let barHeight: CGFloat = 44

    var cropRegionInsets: UIEdgeInsets = .zero
    var maxCropRegion: CGRect = .zero
    var defaultCropBoxCenter: CGPoint = .zero
    var defaultCropBoxSize: CGSize = .zero

    var straightenAngle: CGFloat = 0.0
    var rotationAngle: CGFloat = 0.0
    var flipAngle: CGFloat = 0.0

    var panBeginningPoint: CGPoint = .zero
    var panBeginningCropBoxEdge: CropBoxEdge = .none
    var panBeginningCropBoxFrame: CGRect = .zero

    var manualZoomed: Bool = false

    var needReload: Bool = false
    var defaultCropperState: CropperState?
    var stasisTimer: Timer?
    var stasisThings: (() -> Void)?

    open var isCurrentlyInDefalutState: Bool {
        isCurrentlyInState(defaultCropperState)
    }

    var totalAngle: CGFloat {
        return autoHorizontalOrVerticalAngle(straightenAngle + rotationAngle + flipAngle)
    }

    lazy var scrollViewContainer: ScrollViewContainer = ScrollViewContainer(frame: self.view.bounds)

    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.defaultCropBoxSize.width, height: self.defaultCropBoxSize.height))
        sv.delegate = self
        sv.center = self.backgroundView.convert(defaultCropBoxCenter, to: scrollViewContainer)
        sv.bounces = true
        sv.bouncesZoom = true
        sv.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        sv.alwaysBounceVertical = true
        sv.alwaysBounceHorizontal = true
        sv.minimumZoomScale = 1
        sv.maximumZoomScale = 20
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.clipsToBounds = false
        sv.contentSize = self.defaultCropBoxSize
        //// debug
        // sv.layer.borderColor = UIColor.green.cgColor
        // sv.layer.borderWidth = 1
        // sv.showsVerticalScrollIndicator = true
        // sv.showsHorizontalScrollIndicator = true

        return sv
    }()

    lazy var imageView: UIImageView = {
        let iv = UIImageView(image: self.originalImage)
        iv.backgroundColor = .clear
        return iv
    }()

    lazy var cropBoxPanGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(cropBoxPan(_:)))
        pan.delegate = self
        return pan
    }()

    // MARK: Custom UI

    lazy var backgroundView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor(white: 0.06, alpha: 1)
        return view
    }()

    open lazy var bottomView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: self.view.height - 100, width: self.view.width, height: 100))
        view.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth]
        return view
    }()

    open lazy var topBar: UIView = {
        let topBar = TopBar(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.safeAreaInsets.top + barHeight))
        topBar.flipButton.addTarget(self, action: #selector(flipButtonPressed(_:)), for: .touchUpInside)
        topBar.rotateButton.addTarget(self, action: #selector(rotateButtonPressed(_:)), for: .touchUpInside)
        topBar.aspectRationButton.addTarget(self, action: #selector(aspectRationButtonPressed(_:)), for: .touchUpInside)
        return topBar
    }()

    open lazy var toolbar: UIView = {
        let toolbar = Toolbar(frame: CGRect(x: 0, y: 0, width: self.view.width, height: view.safeAreaInsets.bottom + barHeight))
        toolbar.doneButton.addTarget(self, action: #selector(confirmButtonPressed(_:)), for: .touchUpInside)
        toolbar.cancelButton.addTarget(self, action: #selector(cancelButtonPressed(_:)), for: .touchUpInside)
        toolbar.resetButton.addTarget(self, action: #selector(resetButtonPressed(_:)), for: .touchUpInside)

        return toolbar
    }()

    let verticalAspectRatios: [AspectRatio] = [
        .original,
        .freeForm,
        .square,
        .ratio(width: 9, height: 16),
        .ratio(width: 8, height: 10),
        .ratio(width: 5, height: 7),
        .ratio(width: 3, height: 4),
        .ratio(width: 3, height: 5),
        .ratio(width: 2, height: 3)
    ]

    open lazy var overlay: Overlay = Overlay(frame: self.view.bounds)

    public lazy var angleRuler: AngleRuler = {
        let ar = AngleRuler(frame: CGRect(x: 0, y: 0, width: view.width, height: 80))
        ar.addTarget(self, action: #selector(angleRulerValueChanged(_:)), for: .valueChanged)
        ar.addTarget(self, action: #selector(angleRulerTouchEnded(_:)), for: [.editingDidEnd])
        return ar
    }()

    public lazy var aspectRatioPicker: AspectRatioPicker = {
        let picker = AspectRatioPicker(frame: CGRect(x: 0, y: 0, width: view.width, height: 80))
        picker.isHidden = true
        picker.delegate = self
        return picker
    }()

    @objc
    func angleRulerValueChanged(_: AnyObject) {
        toolbar.isUserInteractionEnabled = false
        topBar.isUserInteractionEnabled = false
        scrollViewContainer.isUserInteractionEnabled = false
        setStraightenAngle(CGFloat(angleRuler.value * CGFloat.pi / 180.0))
    }

    @objc
    func angleRulerTouchEnded(_: AnyObject) {
        UIView.animate(withDuration: 0.25, animations: {
            self.overlay.gridLinesAlpha = 0
            self.overlay.blur = true
        }, completion: { _ in
            self.toolbar.isUserInteractionEnabled = true
            self.topBar.isUserInteractionEnabled = true
            self.scrollViewContainer.isUserInteractionEnabled = true
            self.overlay.gridLinesCount = 2
        })
    }

    // MARK: - Override

    deinit {
        self.cancelStasis()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true
        view.clipsToBounds = true

        // TODO: transition

        if originalImage.size.width < 1 || originalImage.size.height < 1 {
            // TODO: show alert and dismiss
            return
        }

        view.backgroundColor = .clear

        scrollView.addSubview(imageView)

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }

        scrollViewContainer.scrollView = scrollView
        scrollViewContainer.addSubview(scrollView)
        scrollViewContainer.addGestureRecognizer(cropBoxPanGesture)
        scrollView.panGestureRecognizer.require(toFail: cropBoxPanGesture)

        backgroundView.addSubview(scrollViewContainer)
        backgroundView.addSubview(overlay)
        bottomView.addSubview(aspectRatioPicker)
        bottomView.addSubview(angleRuler)
        bottomView.addSubview(toolbar)

        view.addSubview(backgroundView)
        view.addSubview(bottomView)
        view.addSubview(topBar)
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Layout when self.view finish layout and never layout before, or self.view need reload
        if let viewFrame = defaultCropperState?.viewFrame,
            viewFrame.equalTo(view.frame) {
            if needReload {
                needReload = false
                relayoutKeepingCrop()
            }
        } else if hasUsableLayout {
            // The view changed size, for example when iPhone Duo folds or unfolds, or the window is resized.
            needReload = false
            relayoutKeepingCrop()
        } else {
            needReload = false
            resetToDefaultLayout()

            if let initialState = initialState {
                // The initial state may have been recorded at another view size.
                restoreState(stateAdaptedToCurrentLayout(initialState, previousDefaultCropBoxCenter: nil))
                if !initialState.viewFrame.equalTo(view.frame) {
                    matchScrollViewAndCropView()
                }
                updateButtons()
            }
        }
    }

    /// Whether the cropper has already been laid out at a real size, so its current state is worth keeping.
    private var hasUsableLayout: Bool {
        guard let previousLayout = defaultCropperState else { return false }
        return previousLayout.viewFrame.width > 1 && previousLayout.viewFrame.height > 1 && imageView.bounds.width > 0
    }

    /// Lays the cropper out for the current view size and keeps the crop the person is working on.
    private func relayoutKeepingCrop() {
        // Read the state while the scene still has the previous layout.
        let currentState = saveState()
        let previousDefaultCropBoxCenter = defaultCropBoxCenter

        resetToDefaultLayout()
        restoreState(stateAdaptedToCurrentLayout(currentState, previousDefaultCropBoxCenter: previousDefaultCropBoxCenter))
        // Fit the crop box to the new crop region, keeping the same part of the image inside it.
        matchScrollViewAndCropView()
        updateButtons()
    }

    /// Maps a state recorded at another layout onto the current one. Call right after `resetToDefaultLayout()`.
    ///
    /// The image's base size is the image fitted into the crop region, so it changes with the view size.
    /// Scaling the recorded scene by that change keeps the crop box over the same part of the image.
    /// Pass the previous layout's default crop box center to keep an off-center crop box in place;
    /// with `nil`, the crop box is centered.
    func stateAdaptedToCurrentLayout(_ state: CropperState, previousDefaultCropBoxCenter: CGPoint?) -> CropperState {
        guard state.imageViewBoundsSize.width > 0, imageView.bounds.width > 0 else {
            return state
        }

        let scale = imageView.bounds.width / state.imageViewBoundsSize.width
        let previousCenter = previousDefaultCropBoxCenter ?? CGPoint(x: state.cropBoxFrame.midX, y: state.cropBoxFrame.midY)
        let cropBoxCenter = CGPoint(x: defaultCropBoxCenter.x + (state.cropBoxFrame.midX - previousCenter.x) * scale,
                                    y: defaultCropBoxCenter.y + (state.cropBoxFrame.midY - previousCenter.y) * scale)
        let contentOffset = CGPoint(x: state.scrollViewContentOffset.x * scale,
                                    y: state.scrollViewContentOffset.y * scale)

        var adapted = state
        adapted.viewFrame = view.frame
        adapted.cropBoxFrame = CGRect(center: cropBoxCenter,
                                      size: CGSize(width: state.cropBoxFrame.width * scale,
                                                   height: state.cropBoxFrame.height * scale))
        // resetToDefaultLayout() already centered the scroll view for the current layout.
        adapted.scrollViewCenter = scrollView.center
        adapted.scrollViewContentOffset = contentOffset
        adapted.scrollViewBounds = CGRect(origin: contentOffset,
                                          size: CGSize(width: state.scrollViewBounds.width * scale,
                                                       height: state.scrollViewBounds.height * scale))
        adapted.imageViewBoundsSize = imageView.bounds.size
        return adapted
    }

    open override var prefersStatusBarHidden: Bool {
        return true
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    open override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .top
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if !view.size.isEqual(to: size, accuracy: 0.0001) {
            needReload = true
        }
        super.viewWillTransition(to: size, with: coordinator)
    }

    // MARK: - User Interaction

    @objc
    func cropBoxPan(_ pan: UIPanGestureRecognizer) {
        guard isCropBoxPanEnabled else {
            return
        }
        let point = pan.location(in: view)

        if pan.state == .began {
            cancelStasis()
            panBeginningPoint = point
            panBeginningCropBoxFrame = overlay.cropBoxFrame
            panBeginningCropBoxEdge = nearestCropBoxEdgeForPoint(point: panBeginningPoint)
            overlay.blur = false
            overlay.gridLinesAlpha = 1
            topBar.isUserInteractionEnabled = false
            bottomView.isUserInteractionEnabled = false
        }

        if pan.state == .ended || pan.state == .cancelled {
            stasisAndThenRun {
                self.matchScrollViewAndCropView(animated: true, targetCropBoxFrame: self.overlay.cropBoxFrame, extraZoomScale: 1, blurLayerAnimated: true, animations: {
                    self.overlay.gridLinesAlpha = 0
                    self.overlay.blur = true
                }, completion: {
                    self.topBar.isUserInteractionEnabled = true
                    self.bottomView.isUserInteractionEnabled = true
                    self.updateButtons()
                })
            }
        } else {
            updateCropBoxFrameWithPanGesturePoint(point)
        }
    }

    @objc
    func cancelButtonPressed(_: UIButton) {
        delegate?.cropperDidCancel(self)
    }

    @objc
    func confirmButtonPressed(_: UIButton) {
        delegate?.cropperDidConfirm(self, state: saveState())
    }

    @objc
    func resetButtonPressed(_: UIButton) {
        overlay.blur = false
        overlay.gridLinesAlpha = 0
        overlay.cropBoxAlpha = 0
        topBar.isUserInteractionEnabled = false
        bottomView.isUserInteractionEnabled = false

        UIView.animate(withDuration: 0.25, animations: {
            self.resetToDefaultLayout()
        }, completion: { _ in
            UIView.animate(withDuration: 0.25, animations: {
                self.overlay.cropBoxAlpha = 1
                self.overlay.blur = true
            }, completion: { _ in
                self.topBar.isUserInteractionEnabled = true
                self.bottomView.isUserInteractionEnabled = true
            })
        })
    }

    @objc
    func flipButtonPressed(_: UIButton) {
        flip()
    }

    @objc
    func rotateButtonPressed(_: UIButton) {
        rotate90degrees()
    }

    @objc
    func aspectRationButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

        angleRuler.isHidden = sender.isSelected
        aspectRatioPicker.isHidden = !sender.isSelected
    }

// MARK: - Private Methods

    open var cropBoxFrame: CGRect {
        get {
            return overlay.cropBoxFrame
        }
        set {
            overlay.cropBoxFrame = safeCropBoxFrame(newValue)
        }
    }

    open func resetToDefaultLayout() {
        let margin: CGFloat = 20

        topBar.frame = CGRect(x: 0, y: 0, width: view.width, height: view.safeAreaInsets.top + barHeight)
        toolbar.size = CGSize(width: view.width, height: view.safeAreaInsets.bottom + barHeight)
        bottomView.size = CGSize(width: view.width, height: toolbar.height + angleRuler.height + margin)
        bottomView.bottom = view.height
        toolbar.bottom = bottomView.height
        angleRuler.bottom = toolbar.top - margin
        // Fit the ruler to the current width, inside each side's safe-area inset.
        angleRuler.left = view.safeAreaInsets.left
        angleRuler.width = view.width - view.safeAreaInsets.left - view.safeAreaInsets.right
        aspectRatioPicker.frame = angleRuler.frame

        let topHeight = topBar.isHidden ? view.safeAreaInsets.top : topBar.height
        let toolbarHeight = toolbar.isHidden ? view.safeAreaInsets.bottom : toolbar.height
        let bottomHeight = (angleRuler.isHidden && aspectRatioPicker.isHidden) ? toolbarHeight : bottomView.height
        cropRegionInsets = UIEdgeInsets(top: cropContentInset.top + topHeight,
                                        left: cropContentInset.left + view.safeAreaInsets.left,
                                        bottom: cropContentInset.bottom + bottomHeight,
                                        right: cropContentInset.right + view.safeAreaInsets.right)

        maxCropRegion = CGRect(x: cropRegionInsets.left,
                               y: cropRegionInsets.top,
                               width: view.width - cropRegionInsets.left - cropRegionInsets.right,
                               height: view.height - cropRegionInsets.top - cropRegionInsets.bottom)
        defaultCropBoxCenter = CGPoint(x: view.width / 2.0, y: cropRegionInsets.top + maxCropRegion.size.height / 2.0)
        defaultCropBoxSize = {
            var size: CGSize
            let scaleW = self.originalImage.size.width / self.maxCropRegion.size.width
            let scaleH = self.originalImage.size.height / self.maxCropRegion.size.height
            let scale = max(scaleW, scaleH)
            size = CGSize(width: self.originalImage.size.width / scale, height: self.originalImage.size.height / scale)
            return size
        }()

        backgroundView.frame = view.bounds
        scrollViewContainer.frame = CGRect(x: 0, y: topHeight, width: view.width, height: view.height - topHeight - bottomHeight)

        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 20
        scrollView.zoomScale = 1
        scrollView.transform = .identity
        scrollView.bounds = CGRect(x: 0, y: 0, width: defaultCropBoxSize.width, height: defaultCropBoxSize.height)
        scrollView.contentSize = defaultCropBoxSize
        scrollView.contentOffset = .zero
        scrollView.center = backgroundView.convert(defaultCropBoxCenter, to: scrollViewContainer)
        imageView.transform = .identity
        imageView.frame = scrollView.bounds
        imageView.image = originalImage
        overlay.frame = backgroundView.bounds
        overlay.cropBoxFrame = CGRect(center: defaultCropBoxCenter, size: defaultCropBoxSize)

        straightenAngle = 0
        rotationAngle = 0
        flipAngle = 0
        aspectRatioLocked = false
        currentAspectRatioValue = 1

        if isCircular {
            isCropBoxPanEnabled = false
            overlay.isCircular = true
            topBar.isHidden = true
            aspectRatioPicker.isHidden = true
            angleRuler.isHidden = true
            cropBoxFrame = CGRect(center: defaultCropBoxCenter, size: CGSize(width: maxCropRegion.size.width, height: maxCropRegion.size.width))
            matchScrollViewAndCropView()
        } else {
            if originalImage.size.width / originalImage.size.height < cropBoxMinSize / maxCropRegion.size.height { // very long
                cropBoxFrame = CGRect(x: (view.width - cropBoxMinSize) / 2, y: cropRegionInsets.top, width: cropBoxMinSize, height: maxCropRegion.size.height)
                matchScrollViewAndCropView()
            } else if originalImage.size.height / originalImage.size.width < cropBoxMinSize / maxCropRegion.size.width { // very wide
                cropBoxFrame = CGRect(x: cropRegionInsets.left, y: cropRegionInsets.top + (maxCropRegion.size.height - cropBoxMinSize) / 2, width: maxCropRegion.size.width, height: cropBoxMinSize)
                matchScrollViewAndCropView()
            }
        }

        defaultCropperState = saveState()

        angleRuler.value = 0
        if overlay.cropBoxFrame.size.width > overlay.cropBoxFrame.size.height {
            aspectRatioPicker.aspectRatios = verticalAspectRatios.map { $0.rotated }
        } else {
            aspectRatioPicker.aspectRatios = verticalAspectRatios
        }
        aspectRatioPicker.rotated = false
        aspectRatioPicker.selectedAspectRatio = .freeForm
        updateButtons()
    }

    func updateButtons() {
        if let toolbar = self.toolbar as? Toolbar {
            toolbar.resetButton.isHidden = isCurrentlyInDefalutState
            if initialState != nil {
                toolbar.doneButton.isEnabled = !isCurrentlyInInitialState
            } else {
                toolbar.doneButton.isEnabled = true//!isCurrentlyInDefalutState
            }
        }
    }

    func scrollViewZoomScaleToBounds() -> CGFloat {
        let scaleW = scrollView.bounds.size.width / imageView.bounds.size.width
        let scaleH = scrollView.bounds.size.height / imageView.bounds.size.height
        return max(scaleW, scaleH)
    }

    func willSetScrollViewZoomScale(_ zoomScale: CGFloat) {
        if zoomScale > scrollView.maximumZoomScale {
            scrollView.maximumZoomScale = zoomScale
        }
        if zoomScale < scrollView.minimumZoomScale {
            scrollView.minimumZoomScale = zoomScale
        }
    }

    func photoTranslation() -> CGPoint {
        let rect = imageView.convert(imageView.bounds, to: view)
        let point = CGPoint(x: rect.origin.x + rect.size.width / 2, y: rect.origin.y + rect.size.height / 2)
        let zeroPoint = CGPoint(x: view.frame.width / 2, y: defaultCropBoxCenter.y)

        return CGPoint(x: point.x - zeroPoint.x, y: point.y - zeroPoint.y)
    }

    public static let overlayCropBoxFramePlaceholder: CGRect = .zero

    public func matchScrollViewAndCropView(animated: Bool = false,
                                    targetCropBoxFrame: CGRect = overlayCropBoxFramePlaceholder,
                                    extraZoomScale: CGFloat = 1.0,
                                    blurLayerAnimated: Bool = false,
                                    animations: (() -> Void)? = nil,
                                    completion: (() -> Void)? = nil) {
        var targetCropBoxFrame = targetCropBoxFrame
        if targetCropBoxFrame.equalTo(CropperViewController.overlayCropBoxFramePlaceholder) {
            targetCropBoxFrame = overlay.cropBoxFrame
        }

        let scaleX = maxCropRegion.size.width / targetCropBoxFrame.size.width
        let scaleY = maxCropRegion.size.height / targetCropBoxFrame.size.height

        let scale = min(scaleX, scaleY)

        // calculate the new bounds of crop view
        let newCropBounds = CGRect(x: 0, y: 0, width: scale * targetCropBoxFrame.size.width, height: scale * targetCropBoxFrame.size.height)

        // calculate the new bounds of scroll view
        let rotatedRect = newCropBounds.applying(CGAffineTransform(rotationAngle: totalAngle))
        let width = rotatedRect.size.width
        let height = rotatedRect.size.height

        let cropBoxFrameBeforeZoom = targetCropBoxFrame

        let zoomRect = view.convert(cropBoxFrameBeforeZoom, to: imageView) // zoomRect is base on imageView when scrollView.zoomScale = 1
        let center = CGPoint(x: zoomRect.origin.x + zoomRect.size.width / 2, y: zoomRect.origin.y + zoomRect.size.height / 2)
        let normalizedCenter = CGPoint(x: center.x / (imageView.width / scrollView.zoomScale), y: center.y / (imageView.height / scrollView.zoomScale))

        UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
            self.overlay.setCropBoxFrame(CGRect(center: self.defaultCropBoxCenter, size: newCropBounds.size), blurLayerAnimated: blurLayerAnimated)
            animations?()
            self.scrollView.bounds = CGRect(x: 0, y: 0, width: width, height: height)

            var zoomScale = scale * self.scrollView.zoomScale * extraZoomScale
            let scrollViewZoomScaleToBounds = self.scrollViewZoomScaleToBounds()
            if zoomScale < scrollViewZoomScaleToBounds { // Some area not fill image in the cropbox area
                zoomScale = scrollViewZoomScaleToBounds
            }
            if zoomScale > self.scrollView.maximumZoomScale { // Only rotate can make maximumZoomScale to get bigger
                zoomScale = self.scrollView.maximumZoomScale
            }
            self.willSetScrollViewZoomScale(zoomScale)

            self.scrollView.zoomScale = zoomScale

            let contentOffset = CGPoint(x: normalizedCenter.x * self.imageView.width - self.scrollView.bounds.size.width * 0.5,
                                        y: normalizedCenter.y * self.imageView.height - self.scrollView.bounds.size.height * 0.5)
            self.scrollView.contentOffset = self.safeContentOffsetForScrollView(contentOffset)
        }, completion: { _ in
            completion?()
        })

        manualZoomed = true
    }

    func safeContentOffsetForScrollView(_ contentOffset: CGPoint) -> CGPoint {
        var contentOffset = contentOffset
        contentOffset.x = max(contentOffset.x, 0)
        contentOffset.y = max(contentOffset.y, 0)

        if scrollView.contentSize.height - contentOffset.y <= scrollView.bounds.size.height {
            contentOffset.y = scrollView.contentSize.height - scrollView.bounds.size.height
        }

        if scrollView.contentSize.width - contentOffset.x <= scrollView.bounds.size.width {
            contentOffset.x = scrollView.contentSize.width - scrollView.bounds.size.width
        }

        return contentOffset
    }

    func safeCropBoxFrame(_ cropBoxFrame: CGRect) -> CGRect {
        var cropBoxFrame = cropBoxFrame
        // Upon init, sometimes the box size is still 0, which can result in CALayer issues
        if cropBoxFrame.size.width < .ulpOfOne || cropBoxFrame.size.height < .ulpOfOne {
            return CGRect(center: defaultCropBoxCenter, size: defaultCropBoxSize)
        }

        // clamp the cropping region to the inset boundaries of the screen
        let contentFrame = maxCropRegion
        let xOrigin = contentFrame.origin.x
        let xDelta = cropBoxFrame.origin.x - xOrigin
        cropBoxFrame.origin.x = max(cropBoxFrame.origin.x, xOrigin)
        if xDelta < -.ulpOfOne { // If we clamp the x value, ensure we compensate for the subsequent delta generated in the width (Or else, the box will keep growing)
            cropBoxFrame.size.width += xDelta
        }

        let yOrigin = contentFrame.origin.y
        let yDelta = cropBoxFrame.origin.y - yOrigin
        cropBoxFrame.origin.y = max(cropBoxFrame.origin.y, yOrigin)
        if yDelta < -.ulpOfOne {
            cropBoxFrame.size.height += yDelta
        }

        // given the clamped X/Y values, make sure we can't extend the crop box beyond the edge of the screen in the current state
        let maxWidth = (contentFrame.size.width + contentFrame.origin.x) - cropBoxFrame.origin.x
        cropBoxFrame.size.width = min(cropBoxFrame.size.width, maxWidth)

        let maxHeight = (contentFrame.size.height + contentFrame.origin.y) - cropBoxFrame.origin.y
        cropBoxFrame.size.height = min(cropBoxFrame.size.height, maxHeight)

        // Make sure we can't make the crop box too small
        cropBoxFrame.size.width = max(cropBoxFrame.size.width, cropBoxMinSize)
        cropBoxFrame.size.height = max(cropBoxFrame.size.height, cropBoxMinSize)

        return cropBoxFrame
    }
}

// MARK: UIScrollViewDelegate

extension CropperViewController: UIScrollViewDelegate {

    public func viewForZooming(in _: UIScrollView) -> UIView? {
        return imageView
    }

    public func scrollViewWillBeginZooming(_: UIScrollView, with _: UIView?) {
        cancelStasis()
        overlay.blur = false
        overlay.gridLinesAlpha = 1
        topBar.isUserInteractionEnabled = false
        bottomView.isUserInteractionEnabled = false
    }

    public func scrollViewDidEndZooming(_: UIScrollView, with _: UIView?, atScale _: CGFloat) {
        matchScrollViewAndCropView(animated: true, completion: {
            self.stasisAndThenRun {
                UIView.animate(withDuration: 0.25, animations: {
                    self.overlay.gridLinesAlpha = 0
                    self.overlay.blur = true
                }, completion: { _ in
                    self.topBar.isUserInteractionEnabled = true
                    self.bottomView.isUserInteractionEnabled = true
                    self.updateButtons()
                })

                self.manualZoomed = true
            }
        })
    }

    public func scrollViewWillBeginDragging(_: UIScrollView) {
        cancelStasis()
        overlay.blur = false
        overlay.gridLinesAlpha = 1
        topBar.isUserInteractionEnabled = false
        bottomView.isUserInteractionEnabled = false
    }

    public func scrollViewDidEndDragging(_: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            matchScrollViewAndCropView(animated: true, completion: {
                self.stasisAndThenRun {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.overlay.gridLinesAlpha = 0
                        self.overlay.blur = true
                    }, completion: { _ in
                        self.topBar.isUserInteractionEnabled = true
                        self.bottomView.isUserInteractionEnabled = true
                        self.updateButtons()
                    })
                }
            })
        }
    }

    public func scrollViewDidEndDecelerating(_: UIScrollView) {
        matchScrollViewAndCropView(animated: true, completion: {
            self.stasisAndThenRun {
                UIView.animate(withDuration: 0.25, animations: {
                    self.overlay.gridLinesAlpha = 0
                    self.overlay.blur = true
                }, completion: { _ in
                    self.topBar.isUserInteractionEnabled = true
                    self.bottomView.isUserInteractionEnabled = true
                    self.updateButtons()
                })
            }
        })
    }
}

// MARK: UIGestureRecognizerDelegate

extension CropperViewController: UIGestureRecognizerDelegate {

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == cropBoxPanGesture {
            guard isCropBoxPanEnabled else {
                return false
            }
            let tapPoint = gestureRecognizer.location(in: view)

            let frame = overlay.cropBoxFrame

            let d = cropBoxHotArea / 2.0
            let innerFrame = frame.insetBy(dx: d, dy: d)
            let outerFrame = frame.insetBy(dx: -d, dy: -d)

            if innerFrame.contains(tapPoint) || !outerFrame.contains(tapPoint) {
                return false
            }
        }

        return true
    }
}

// MARK: AspectRatioPickerDelegate

extension CropperViewController: AspectRatioPickerDelegate {

    func aspectRatioPickerDidSelectedAspectRatio(_ aspectRatio: AspectRatio) {
        setAspectRatio(aspectRatio)
    }
}

// MARK: Add capability from protocols

extension CropperViewController: Stasisable, AngleAssist, CropBoxEdgeDraggable, AspectRatioSettable {}
