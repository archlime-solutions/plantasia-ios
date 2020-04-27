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

    static var className: String {
        return String(describing: self)
    }

    class func fromNib<T: UIView>(owner: Any? = nil) -> T {
        // swiftlint:disable:next force_cast
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: owner, options: nil)![0] as! T
    }

}
