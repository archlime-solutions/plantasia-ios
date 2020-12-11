//
//  PlantsService.swift
//  Plantasia
//
//  Created by bogdan razvan on 09/11/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import RealmSwift
import FirebaseAnalytics

class PlantsService {

    /// Returns all plants from the DB sorted by index.
    /// - Returns: all plants from the DB.
    /// - Throws: db error.
    func getSortedPlants() throws -> [Plant] {
        let realm = try Realm()
        return Array(realm.objects(Plant.self).sorted(by: { $0.index < $1.index }))
    }

    /// Returns all plants from the DB.
    /// - Returns: all plants from the DB.
    /// - Throws: db error.
    func getPlants() throws -> [Plant] {
        let realm = try Realm()
        return Array(realm.objects(Plant.self))
    }

    /// Checks if plants exist in the DB.
    /// - Returns: the result of the check.
    func plantsExist() -> Bool {
        if let realm = try? Realm() {
            return !realm.objects(Plant.self).isEmpty
        }
        return false
    }

    /// - Returns: Returns the number of days until the next stored plant requires attention (watering or fertilizing).
    /// - Throws: db error.
    func getRequiredAttentionRemainingDays() throws -> Int {
        return try getPlants().map { $0.getRequiredAttentionRemainingDays() }.min() ?? 0
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
    ///   - plant: the plant to be moved,
    /// - Throws: db error.
    func move(_ plant: Plant, fromPosition: Int, toPosition: Int) throws -> [Plant] {
        let realm = try Realm()
        var plants = try getSortedPlants()
        plants.remove(at: fromPosition)
        plants.insert(plant, at: toPosition)
        for (index, plant) in plants.enumerated() {
            try realm.write {
                plant.index = index
            }
        }
        return plants
    }

    /// Marks a plant as watered.
    /// - Parameter plant: the plant to mark as watered.
    /// - Throws: db error.
    func water(_ plant: Plant) throws {
        let realm = try Realm()
        try realm.write {
            plant.water()
            Analytics.logEvent("water_plant", parameters: nil)
            PushNotificationService.shared.scheduleNotifications()
        }
    }

    /// Marks all plants as watered.
    /// - Throws: db error.
    func waterAllPlants() throws {
        let realm = try Realm()
        try realm.write {
            try getSortedPlants().forEach { $0.water() }
            Analytics.logEvent("water_all_plants", parameters: nil)
            PushNotificationService.shared.scheduleNotifications()
        }
    }

    /// Marks all dehydrated plants as watered.
    /// - Throws: db error.
    func waterDehydratedPlants() throws {
        let realm = try Realm()
        try realm.write {
            try getSortedPlants().filter { $0.requiresWatering() }.forEach { $0.water() }
            Analytics.logEvent("water_dehydrated_plants", parameters: nil)
            PushNotificationService.shared.scheduleNotifications()
        }
    }

    /// Marks a plant as fertiized.
    /// - Parameter plant: the plant to mark as fertilized.
    /// - Throws: db error.
    func fertilize(_ plant: Plant) throws {
        let realm = try Realm()
        try realm.write {
            plant.fertilize()
            Analytics.logEvent("fertilize_plant", parameters: nil)
            PushNotificationService.shared.scheduleNotifications()
        }
    }

    /// Marks all plants as fertilized.
    /// - Throws: db error.
    func fertilizeAllPlants() throws {
        let realm = try Realm()
        try realm.write {
            try getSortedPlants().forEach { $0.fertilize() }
            Analytics.logEvent("fertilize_all_plants", parameters: nil)
            PushNotificationService.shared.scheduleNotifications()
        }
    }

    /// Marks all unfertilized plants as fertilized.
    /// - Throws: db error.
    func fertilizeUnfertilizedPlants() throws {
        let realm = try Realm()
        try realm.write {
            try getSortedPlants().filter { $0.requiresFertilizing() }.forEach { $0.fertilize() }
            Analytics.logEvent("fertilize_unfertilized_plants", parameters: nil)
            PushNotificationService.shared.scheduleNotifications()
        }
    }

    /// Creates a plant and saves it in the db.
    /// - Parameter plant: the plant to create.
    /// - Throws: db error.
    func create(_ plant: Plant) throws {
        let realm = try Realm()
        try realm.write {
            plant.index = realm.objects(Plant.self).count
            realm.add(plant)
            Analytics.logEvent("add_plant", parameters: nil)
            PushNotificationService.shared.scheduleNotifications()
        }
    }

    /// Deletes a plant from the db.
    /// - Parameter plant: the plant to remove.
    /// - Throws: db error
    func delete(_ plant: Plant) throws {
        let realm = try Realm()
        try realm.write {
            realm.delete(plant)
            Analytics.logEvent("delete_plant", parameters: nil)
            PushNotificationService.shared.scheduleNotifications()
        }
    }

    /// Updates a plant in the db.
    /// - Parameters:
    ///   - plant: the plant to be updated.
    ///   - name: the new name.
    ///   - descr: the new description.
    ///   - wateringFrequencyDays: the new watering frequency.
    ///   - fertilizingFrequencyDays: the new fertilizing frequency.
    ///   - image: the new image.
    ///   - ownedSinceDate: the new owned-since.
    /// - Throws: db error.
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
            Analytics.logEvent("update_plant", parameters: nil)
            PushNotificationService.shared.scheduleNotifications()
        }

    }

}
