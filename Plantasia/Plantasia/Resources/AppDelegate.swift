//
//  AppDelegate.swift
//  Plantasia
//
//  Created by bogdan razvan on 24/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black232323]
        setupRealmConfiguration()
        return true
    }

    /// Set the new schema version. This must be greater than the previously used version.
    private func setupRealmConfiguration() {
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
            })

        Realm.Configuration.defaultConfiguration = config
        _ = try? Realm()
    }

}