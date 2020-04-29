//
//  UserDefaultsExtensions.swift
//  Plantasia
//
//  Created by bogdan razvan on 28/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Foundation

extension UserDefaults {

    enum Keys {
        static let RemindersTime = "RemindersTimeKey"
    }

    func getRemindersTime() -> Date {
        guard let dateString = string(forKey: Keys.RemindersTime), let date = Date.fromString(dateString) else {
            return Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
        }
        return date
    }

    func set(remindersTime: Date) {
        guard let dateString = remindersTime.toString() else { return }
        set(dateString, forKey: Keys.RemindersTime)
        PushNotificationService.shared.scheduleNotifications()
    }

}
