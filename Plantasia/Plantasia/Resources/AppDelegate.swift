//
//  AppDelegate.swift
//  Plantasia
//
//  Created by bogdan razvan on 24/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black232323]
        DatabaseConfigurator.shared.start()
        UNUserNotificationCenter.current().delegate = PushNotificationService.shared
        UIApplication.shared.applicationIconBadgeNumber = 0
        FirebaseApp.configure()
        return true
    }

}
