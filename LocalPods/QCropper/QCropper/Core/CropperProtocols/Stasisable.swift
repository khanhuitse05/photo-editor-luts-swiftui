//
//  Stasisable.swift
//
//  Created by Chen Qizhi on 2019/10/18.
//

import UIKit

// MARK: Stasis

protocol Stasisable: AnyObject {
    var stasisTimer: Timer? { get set }
    var stasisThings: (() -> Void)? { get set }

    func stasisAndThenRun(_ closure: @escaping () -> Void)
    func cancelStasis()
}

extension Stasisable where Self: UIViewController {
    // stasis like Zhonya's Hourglass.
    func stasisAndThenRun(_ closure: @escaping () -> Void) {
        cancelStasis()
        stasisTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            self?.view.isUserInteractionEnabled = false
            if self?.stasisThings != nil {
                self?.stasisThings?()
            }
            self?.cancelStasis()
        })
        stasisThings = closure
    }

    func cancelStasis() {
        guard stasisTimer != nil else {
            return
        }
        stasisTimer?.invalidate()
        stasisTimer = nil
        stasisThings = nil
        view.isUserInteractionEnabled = true
    }
}
