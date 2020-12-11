//
//  SettingsViewModel.swift
//  Plantasia
//
//  Created by bogdan razvan on 28/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Bond

class SettingsViewModel: BaseViewModel, EventTransmitter {

    enum Event {
        case didSetReminderTime
    }

    // MARK: - Properties
    var error = Observable<GeneralError?>(nil)
    var event = Observable<Event?>(nil)

    // MARK: - Internal
    func setReminderTime(_ date: Date) {
        UserDefaults.standard.set(remindersTime: date)
        PushNotificationService.shared.scheduleNotifications()
        event.value = .didSetReminderTime
    }

}
