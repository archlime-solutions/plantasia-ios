//
//  PlantDetailsViewModel.swift
//  Plantasia
//
//  Created by bogdan razvan on 27/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Bond
import RealmSwift

class PlantDetailsViewModel: BaseViewModel, EventTransmitter {

    enum Event {
        case didWaterPlant
        case didFertilizePlant
    }

    var error = Observable<GeneralError?>(nil)
    var event = Observable<Event?>(nil)
    var plant: Observable<Plant>

    init(plant: Plant) {
        self.plant = Observable<Plant>(plant)
    }

    func waterPlant() {
        if let realm = try? Realm() {
            try? realm.write {
                plant.value.water()
                event.value = .didWaterPlant
            }
        }
    }

    func fertilizePlant() {
        if let realm = try? Realm() {
            try? realm.write {
                plant.value.fertilize()
                event.value = .didFertilizePlant
            }
        }
    }

}
