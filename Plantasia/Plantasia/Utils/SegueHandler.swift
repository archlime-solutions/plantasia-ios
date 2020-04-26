//
//  SegueHandler.swift
//  Plantasia
//
//  Created by bogdan razvan on 25/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit

/// Protocol to be adapted by every UIViewController which works with segues.
/// Each of these UIViewController must declare an enum of type SegueIdentifier in which to declare the identifiers of each segue.
public protocol SegueHandler {
    associatedtype SegueIdentifier: RawRepresentable
}

/// Default implementation of the method defined in the protocol above.
extension SegueHandler where Self: UIViewController, SegueIdentifier.RawValue == String {
    public func segueIdentifier(for segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier,
            let segueIdentifier = SegueIdentifier(rawValue: identifier)
            else { fatalError("Unknown segue: \(segue))") }
        return segueIdentifier
    }

    public func performSegue(withIdentifier segueIdentifier: SegueIdentifier, sender: Any? = nil) {
        performSegue(withIdentifier: segueIdentifier.rawValue, sender: sender)
    }
}
