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

        migrateRealmConfigToAppGroup()
        setupRealmConfiguration()
        migratePlantImagesToAppGroup()

        UNUserNotificationCenter.current().delegate = PushNotificationService.shared
        UIApplication.shared.applicationIconBadgeNumber = 0
        return true
    }

    /// Set the new schema version. This must be greater than the previously used version.
    private func setupRealmConfiguration() {
        var config = Realm.Configuration(
            schemaVersion: Constants.realmDBVersion,
            migrationBlock: nil)

        if let sharedDirectory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.applicationGroup) {
            let sharedRealmURL = sharedDirectory.appendingPathComponent(Constants.sharedRealmUrl)
            config.fileURL = sharedRealmURL
        }

        Realm.Configuration.defaultConfiguration = config
        _ = try? Realm()
    }

    /// Migrates the plant images from the default container to the application group container so they are available in the iMessage extension.
    private func migratePlantImagesToAppGroup() {
        if !UserDefaults.standard.didMigratePlantImagesToAppGroup() {
            do {
                let realm = try Realm()
                let plants = Array(realm.objects(Plant.self))
                for plant in plants {
                    guard let photoUUID = plant.photoUUID,
                        let documentURL = FileManager.default.urls(for: .documentDirectory,
                                                                   in: FileManager.SearchPathDomainMask.userDomainMask).first,
                        case let filePath = documentURL.appendingPathComponent(photoUUID + ".png"),
                        let fileData = FileManager.default.contents(atPath: filePath.path),
                        let image = UIImage(data: fileData)
                        else { return }
                    try realm.write {
                        plant.setImage(image)
                    }
                }
                UserDefaults.standard.setDidMigratePlantImagesToAppGroup()
            } catch let error {
                print(error.localizedDescription)
                //TODO: log error
            }
        }
    }

    /// Migrates the realm configuration from local DB to application group so it is available in the iMessage extension.
    private func migrateRealmConfigToAppGroup() {
        if !UserDefaults.standard.didMigrateRealmConfigToAppGroup() {
            let fileManager = FileManager.default
            if let originalPath = Realm.Configuration.defaultConfiguration.fileURL,
                let appGroupURL =
                FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.applicationGroup)?.appendingPathComponent(Constants.sharedRealmUrl) {
                do {
                    try _ = fileManager.replaceItemAt(appGroupURL, withItemAt: originalPath)
                    UserDefaults.standard.setDidMigrateRealmConfigToAppGroup()
                } catch let error {
                    print(error.localizedDescription)
                    //TODO: log error
                }
            }
        }
    }

}
