//
//  PlantsService.swift
//  Plantasia
//
//  Created by bogdan razvan on 09/11/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import RealmSwift

class PlantsService {

    /// Returns all plants from the DB sorted by index.
    /// - Returns: all plants from the DB.
    /// - Throws: db error.
    func getSortedPlants() throws -> [Plant] {
        let realm = try Realm()
        return Array(realm.objects(Plant.self).sorted(by: { $0.index < $1.index }))
    }

    /// Checks if plants exist in the DB.
    /// - Returns: the result of the check.
    func plantsExist() -> Bool {
        if let realm = try? Realm() {
            return !realm.objects(Plant.self).isEmpty
        }
        return false
    }

    ///
    /// - Returns: Returns the number of days until any of the stored plants requires attention (watering or fertilizing)
    func getPlantsAttentionRemainingDays() -> Int {
        if let realm = try? Realm() {
            let plants = Array(realm.objects(Plant.self))
            if !plants.isEmpty {
                var minNumberOfDays = Int.max
                for plant in plants {
                    let wateringRemainingDays = plant.getWateringRemainingDays()
                    let fertilizingRemainingDays = plant.getFertilizingRemainingDays()
                    if wateringRemainingDays < minNumberOfDays {
                        minNumberOfDays = wateringRemainingDays
                    }
                    if fertilizingRemainingDays < minNumberOfDays {
                        minNumberOfDays = fertilizingRemainingDays
                    }
                }
                return minNumberOfDays
            }
        }
        return 0
    }

    /// Marks the plants which require attention as watered and fertilized.
    /// - Returns: whether or not the operation was successful.
    func waterAndFertilizeRequiringPlants() -> Bool {
        if let realm = try? Realm() {
            let plants = Array(realm.objects(Plant.self).filter({ $0.requiresAttention() }))
            plants.forEach {
                if $0.requiresWatering() {
                    $0.water()

                }
                if $0.requiresFertilizing() {
                    $0.fertilize()
                }
            }
            return true
        }
        return false
    }

    /// Sorts the plants by the owned since field.
    /// - Throws: db error
    /// - Returns: the sorted plants.
    func sortByOwnedSince() throws -> [Plant] {
        let realm = try Realm()
        let plants = Array(realm.objects(Plant.self).sorted(by: { $0.ownedSinceDate ?? Date() < $1.ownedSinceDate ?? Date() }))
        for (index, plant) in plants.enumerated() {
            try realm.write {
                plant.index = index
            }
        }
        return plants
    }

    /// Sorts the plants by fertilization.
    /// - Throws: db error.
    /// - Returns: the sorted plants.
    func sortByFertilization() throws -> [Plant] {
        let realm = try Realm()
        let plants = Array(realm.objects(Plant.self).sorted(by: { $0.getFertilizingPercentage() < $1.getFertilizingPercentage() }))
        for (index, plant) in plants.enumerated() {
            try realm.write {
                plant.index = index
            }
        }
        return plants
    }

    /// Sorts the plants by hydration.
    /// - Throws: db error.
    /// - Returns: the sorted plants.
    func sortByHydration() throws -> [Plant] {
        let realm = try Realm()
        let plants = Array(realm.objects(Plant.self).sorted(by: { $0.getWateringPercentage() < $1.getWateringPercentage() }))
        for (index, plant) in plants.enumerated() {
            try realm.write {
                plant.index = index
            }
        }
        return plants
    }

    /// Moves a plant from a position to another.
    /// - Parameters:
    ///   - fromPosition: the starting position.
    ///   - toPosition: the destination position.
    /// - Throws: db error.
    func movePlant(fromPosition: Int, toPosition: Int) throws {
        let realm = try Realm()
        let plants = try getSortedPlants()
        for (index, plant) in plants.enumerated() {
            try realm.write {
                plant.index = index
            }
        }
    }

    /// Marks all plants as watered.
    /// - Throws: db error.
    func waterAllPlants() throws {
        let realm = try Realm()
        try realm.write {
            try getSortedPlants().forEach { $0.water() }
            PushNotificationService.shared.scheduleNotifications()
        }
    }

    /// Marks all dehydrated plants as watered.
    /// - Throws: db error.
    func waterDehydratedPlants() throws {
        let realm = try Realm()
        try realm.write {
            try getSortedPlants().filter { $0.requiresWatering() }.forEach { $0.water() }
            PushNotificationService.shared.scheduleNotifications()
        }
    }

    /// Marks all plants as fertilized.
    /// - Throws: db error.
    func fertilizeAllPlants() throws {
        let realm = try Realm()
        try realm.write {
            try getSortedPlants().forEach { $0.fertilize() }
            PushNotificationService.shared.scheduleNotifications()
        }
    }

    /// Marks all unfertilized plants as fertilized.
    /// - Throws: db error.
    func fertilizeUnfertilizedPlants() throws {
        let realm = try Realm()
        try realm.write {
            try getSortedPlants().filter { $0.requiresFertilizing() }.forEach { $0.fertilize() }
            PushNotificationService.shared.scheduleNotifications()
        }
    }

    func create(_ plant: Plant) throws {
        let realm = try Realm()
        try realm.write {
            plant.index = realm.objects(Plant.self).count
            realm.add(plant)
        }
        PushNotificationService.shared.scheduleNotifications()
    }

    func delete(_ plant: Plant) throws {
        let realm = try Realm()
        try realm.write {
            realm.delete(plant)

        }
    }

    // swiftlint:disable:next function_parameter_count
    func update(_ plant: Plant,
                name: String?,
                descr: String?,
                wateringFrequencyDays: Int,
                fertilizingFrequencyDays: Int,
                image: UIImage?,
                ownedSinceDate: Date?) throws {
        let realm = try Realm()
        try realm.write {
            plant.name = name
            plant.descr = descr
            plant.wateringFrequencyDays.value = wateringFrequencyDays
            plant.fertilizingFrequencyDays.value = fertilizingFrequencyDays
            plant.setImage(image)
            plant.ownedSinceDate = ownedSinceDate
        }
        PushNotificationService.shared.scheduleNotifications()
    }
}
