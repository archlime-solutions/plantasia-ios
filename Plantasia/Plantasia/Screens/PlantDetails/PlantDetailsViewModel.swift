//
//  PlantDetailsViewModel.swift
//  Plantasia
//
//  Created by bogdan razvan on 27/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Bond
import RealmSwift

class PlantDetailsViewModel: BaseViewModel {

    enum Event {
        case didRemovePlant
    }

    var error = Observable<GeneralError?>(nil)
    var event = Observable<Event?>(nil)
    var plant: Plant

    init(plant: Plant) {
        self.plant = plant
    }

    func deletePlant() {
        if let realm = try? Realm() {
            try? realm.write {
                realm.delete(plant)
                self.event.value = .didRemovePlant
            }
        }
    }

}
