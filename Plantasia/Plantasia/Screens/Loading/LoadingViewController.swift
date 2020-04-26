//
//  LoadingViewController.swift
//  Plantasia
//
//  Created by bogdan razvan on 24/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit

class LoadingViewController: BaseViewController, AlertPresenter {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //TODO: change these hardcoded 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            let tabBarViewController =
                UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController
            UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = tabBarViewController
        })
    }

    private func setupUI() {
        //TODO: implement
    }

}
