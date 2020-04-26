//
//  AlertPresenter.swift
//  Plantasia
//
//  Created by bogdan razvan on 25/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit

protocol AlertPresenter where Self: UIViewController {

    func showAlert(title: String?,
                   message: String?,
                   buttonText: String?)

    func showAlert(error: GeneralError)

}

extension AlertPresenter {

    func showAlert(title: String?,
                   message: String?,
                   buttonText: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonText, style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func showAlert(error: GeneralError) {
        let alert = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
