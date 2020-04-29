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

    var error = Observable<GeneralError?>(nil)
    var event = Observable<Event?>(nil)

    func setReminderTime(_ date: Date) {
        UserDefaults.standard.set(remindersTime: date)
        event.value = .didSetReminderTime
    }

}
