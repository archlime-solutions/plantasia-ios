//
//  GardenViewModel.swift
//  Plantasia
//
//  Created by bogdan razvan on 26/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Bond
import RealmSwift

class GardenViewModel: BaseViewModel, EventTransmitter {

    enum Event {
        case didGetPlants
    }

    var error = Observable<GeneralError?>(nil)
    var event = Observable<Event?>(nil)
    var plants = [Plant]()

    func getPlants() {
        if let realm = try? Realm() {
            plants = Array(realm.objects(Plant.self))
            print(plants.count)
            event.value = .didGetPlants
        } else {
            //TODO: change these texts
            error.value = GeneralError(title: "error", message: "error")
        }
    }

}
