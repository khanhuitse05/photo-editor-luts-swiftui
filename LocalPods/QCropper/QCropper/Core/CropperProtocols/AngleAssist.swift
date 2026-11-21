//
//  AngleAssist.swift
//
//  Created by Chen Qizhi on 2019/10/18.
//

import UIKit

protocol AngleAssist {
    func standardizeAngle(_ angle: CGFloat) -> CGFloat
    func autoHorizontalOrVerticalAngle(_ angle: CGFloat) -> CGFloat
}

extension AngleAssist {
    // Make angle in 0 - 360 degrees
    func standardizeAngle(_ angle: CGFloat) -> CGFloat {
        var angle = angle
        if angle >= 0, angle <= 2 * CGFloat.pi {
            return angle
        } else if angle < 0 {
            angle += 2 * CGFloat.pi

            return standardizeAngle(angle)
        } else {
            angle -= 2 * CGFloat.pi

            return standardizeAngle(angle)
        }
    }

    func autoHorizontalOrVerticalAngle(_ angle: CGFloat) -> CGFloat {
        var angle = angle
        angle = standardizeAngle(angle)

        let deviation: CGFloat = 0.017444444 // 1 * 3.14 / 180, sync with AngleRuler
        if abs(angle - 0) < deviation {
            angle = 0
        } else if abs(angle - CGFloat.pi / 2.0) < deviation {
            angle = CGFloat.pi / 2.0
        } else if abs(angle - CGFloat.pi) < deviation {
            angle = CGFloat.pi - 0.001 // Handling a iOS bug that causes problems with rotation animations
        } else if abs(angle - CGFloat.pi / 2.0 * 3) < deviation {
            angle = CGFloat.pi / 2.0 * 3
        } else if abs(angle - CGFloat.pi * 2) < deviation {
            angle = CGFloat.pi * 2
        }

        return angle
    }
}
