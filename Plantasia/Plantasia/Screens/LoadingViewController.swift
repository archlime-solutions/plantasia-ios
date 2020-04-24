//
//  LoadingViewController.swift
//  Plantasia
//
//  Created by bogdan razvan on 24/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit

class LoadingViewController: BaseViewController {

    @IBAction func buttonPressed(_ sender: Any) {
        guard let viewController =
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController else { return }
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }

}
