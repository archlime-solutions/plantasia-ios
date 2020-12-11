//
//  LoadingViewController.swift
//  Plantasia
//
//  Created by bogdan razvan on 24/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit

class LoadingViewController: BaseViewController, AlertPresenter {

    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            let tabBarViewController =
                UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            window?.rootViewController = tabBarViewController
            UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: { }, completion: { _ in })
        })
    }

}
