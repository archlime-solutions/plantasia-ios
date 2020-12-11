//
//  UserDefaultsExtensions.swift
//  Plantasia
//
//  Created by bogdan razvan on 28/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Foundation

extension UserDefaults {

    private enum Keys {
        static let remindersTime = "RemindersTimeKey"
        static let didMigratePlantImagesToAppGroup = "DidMigratePlantImagesToAppGroupKey"
        static let didMigrateRealmConfigToAppGroup = "DidMigrateRealmConfigToAppGroupKey"
        static let didShowWhatsInV110 = "DidShowWhatsInV1.1.0"
    }

    func getRemindersTime() -> Date {
        guard let dateString = string(forKey: Keys.remindersTime), let date = Date.fromString(dateString) else {
            return Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
        }
        return date
    }

    func set(remindersTime: Date) {
        guard let dateString = remindersTime.toString() else { return }
        set(dateString, forKey: Keys.remindersTime)
    }

    func didMigratePlantImagesToAppGroup() -> Bool {
        return bool(forKey: Keys.didMigratePlantImagesToAppGroup)
    }

    func setDidMigratePlantImagesToAppGroup() {
        set(true, forKey: Keys.didMigratePlantImagesToAppGroup)
    }

    func didMigrateRealmConfigToAppGroup() -> Bool {
        return bool(forKey: Keys.didMigrateRealmConfigToAppGroup)
    }

    func setDidMigrateRealmConfigToAppGroup() {
        set(true, forKey: Keys.didMigrateRealmConfigToAppGroup)
    }

    func didShowWhatsInV110() -> Bool {
        return bool(forKey: Keys.didShowWhatsInV110)
    }

    func setDidShowWhatsInV110() {
        set(true, forKey: Keys.didShowWhatsInV110)
    }

}
