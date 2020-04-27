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
        case didLoadPlants
    }

    enum SortingCriteria {
        case hydration
        case fertilization
        case dateAdded
        case custom
    }

    var error = Observable<GeneralError?>(nil)
    var event = Observable<Event?>(nil)
    var plants = [Plant]()

    var sortingCriteria: SortingCriteria = .dateAdded {
        didSet {
            switch sortingCriteria {
            case .hydration:
                sortByHydration()
            case .fertilization:
                sortByFertilization()
            case .dateAdded:
                sortByDateAdded()
            case .custom:
                //TODO: implement
                break
            }
        }
    }

    func loadPlants() {
        if let realm = try? Realm() {
            plants = Array(realm.objects(Plant.self).sorted(by: { $0.index < $1.index }))
            plants.forEach { $0.loadImage() }
            event.value = .didLoadPlants
        } else {
            //TODO: change these texts
            error.value = GeneralError(title: "error", message: "error")
        }
    }

    func movePlant(_ plant: Plant, fromPosition: Int, toPosition: Int) {
        plants.remove(at: fromPosition)
        plants.insert(plant, at: toPosition)

        if let realm = try? Realm() {
            for (index, plant) in plants.enumerated() {
                try? realm.write {
                    plant.index = index
                }
            }
        }
    }

    private func sortByHydration() {
        plants = plants.sorted(by: { $0.getWateringPercent() < $1.getWateringPercent() })
        if let realm = try? Realm() {
            for (index, plant) in plants.enumerated() {
                try? realm.write {
                    plant.index = index
                }
            }
        }
        event.value = .didLoadPlants
    }

    private func sortByFertilization() {
        plants = plants.sorted(by: { $0.getFertilizingPercent() < $1.getFertilizingPercent() })
        if let realm = try? Realm() {
            for (index, plant) in plants.enumerated() {
                try? realm.write {
                    plant.index = index
                }
            }
        }
        event.value = .didLoadPlants
    }

    private func sortByDateAdded() {
        plants = plants.sorted(by: { $0.id < $1.id })
        if let realm = try? Realm() {
            for (index, plant) in plants.enumerated() {
                try? realm.write {
                    plant.index = index
                }
            }
        }
        event.value = .didLoadPlants
    }

}
