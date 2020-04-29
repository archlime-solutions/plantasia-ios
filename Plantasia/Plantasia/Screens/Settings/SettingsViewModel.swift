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

    //TODO: trimite notificari cu emojii cu plante random de fiecare data :D 
    func setReminderTime(_ date: Date) {
        print(date)
        UserDefaults.standard.set(remindersTime: date)
        event.value = .didSetReminderTime
    }

}
