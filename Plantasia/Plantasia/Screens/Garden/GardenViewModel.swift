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
        case didWaterAllPlants
        case didFertilizeAllPlants
    }

    enum SortingCriteria {
        case hydration
        case fertilization
        case dateAdded
    }

    var error = Observable<GeneralError?>(nil)
    var event = Observable<Event?>(nil)
    var plants = [Plant]()
    var selectedPlant: Plant?

    var sortingCriteria: SortingCriteria = .dateAdded {
        didSet {
            switch sortingCriteria {
            case .hydration:
                sortByHydration()
            case .fertilization:
                sortByFertilization()
            case .dateAdded:
                sortByDateAdded()
            }
        }
    }

    func loadPlants() {
        if let realm = try? Realm() {
            plants = Array(realm.objects(Plant.self).sorted(by: { $0.index < $1.index }))
            event.value = .didLoadPlants
        } else {
            error.value = GeneralError(title: "Could not load your plants", message: "Please try restarting the application.")
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

    func waterAllPlants() {
        if let realm = try? Realm() {
            try? realm.write {
                plants.forEach { $0.water() }
                event.value = .didWaterAllPlants
            }
        }
    }

    func fertilizeAllPlants() {
        if let realm = try? Realm() {
            try? realm.write {
                plants.forEach { $0.fertilize() }
                event.value = .didFertilizeAllPlants
            }
        }
    }

    private func sortByHydration() {
        plants = plants.sorted(by: { $0.getWateringPercentage() < $1.getWateringPercentage() })
        if let realm = try? Realm() {
            for (index, plant) in plants.enumerated() {
                try? realm.write {
                    plant.index = index
                    event.value = .didFertilizeAllPlants
                }
            }
        }
        event.value = .didLoadPlants
    }

    private func sortByFertilization() {
        plants = plants.sorted(by: { $0.getFertilizingPercentage() < $1.getFertilizingPercentage() })
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
