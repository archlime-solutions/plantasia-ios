//
//  AlertPresenter.swift
//  Plantasia
//
//  Created by bogdan razvan on 25/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit

protocol AlertPresenter where Self: UIViewController {

    // swiftlint:disable:next function_parameter_count
    func showAlert(title: String?,
                   message: String?,
                   buttonText: String?,
                   buttonHandler: (() -> Void)?,
                   buttonStyle: UIAlertAction.Style,
                   showCancelButton: Bool)

    func showAlert(error: GeneralError)

}

extension AlertPresenter {

    func showAlert(title: String?,
                   message: String?,
                   buttonText: String?,
                   buttonHandler: (() -> Void)? = nil,
                   buttonStyle: UIAlertAction.Style = .default,
                   showCancelButton: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonText, style: buttonStyle, handler: { _ in buttonHandler?() })
        alert.addAction(action)
        alert.preferredAction = action
        if showCancelButton {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
        present(alert, animated: true, completion: nil)
    }

    func showAlert(error: GeneralError) {
        let alert = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
