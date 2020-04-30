//
//  UIViewExtensions.swift
//  Plantasia
//
//  Created by bogdan razvan on 25/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit

extension UIView {

    func flash() {
        let initialAlpha = alpha
        UIView.animate(withDuration: 0.25) {
            self.alpha = initialAlpha - 0.5
            self.layoutIfNeeded()

            UIView.animate(withDuration: 0.25) {
                self.alpha = initialAlpha
            }
        }
    }

    func startWiggling() {
        let transformAnim = CAKeyframeAnimation(keyPath: "transform")
        transformAnim.values = [NSValue(caTransform3D: CATransform3DMakeRotation(0.04, 0.0, 0.0, 1.0)),
                                NSValue(caTransform3D: CATransform3DMakeRotation(-0.04, 0, 0, 1))]
        transformAnim.autoreverses = true
        transformAnim.duration = 0.105
        transformAnim.repeatCount = Float.infinity
        layer.add(transformAnim, forKey: "transform")
    }

    static var className: String {
        return String(describing: self)
    }

    class func fromNib<T: UIView>(owner: Any? = nil) -> T {
        // swiftlint:disable:next force_cast
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: owner, options: nil)![0] as! T
    }

    func animateScale() {
        UIView.animate(withDuration: 0.2,
                       animations: {
                           self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                       },
                       completion: { _ in
                           UIView.animate(withDuration: 0.2) {
                               self.transform = CGAffineTransform.identity
                           }
                       })
    }

}
