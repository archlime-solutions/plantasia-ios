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

    // MARK: - Properties
    var error = Observable<GeneralError?>(nil)
    var event = Observable<Event?>(nil)
    var plant: Observable<Plant>

    // MARK: - Lifecycle
    init(plant: Plant) {
        self.plant = Observable<Plant>(plant)
    }

    // MARK: - Internal
    func waterPlant() {
        if let realm = try? Realm() {
            try? realm.write {
                plant.value.water()
                PushNotificationService.shared.scheduleNotifications()
                event.value = .didWaterPlant
            }
        }
    }

    func fertilizePlant() {
        if let realm = try? Realm() {
            try? realm.write {
                plant.value.fertilize()
                PushNotificationService.shared.scheduleNotifications()
                event.value = .didFertilizePlant
            }
        }
    }

    func setPhotos(_ photos: [PlantPhoto]) {
        if let realm = try? Realm() {
            let existingPhotosSet = Set(plant.value.photos)
            let newPhotosSet = Set(photos)
            let photosToDelete = existingPhotosSet.subtracting(newPhotosSet)
            let photosToAdd = newPhotosSet.subtracting(existingPhotosSet)

            photosToAdd.forEach { photo in
                try? realm.write {
                    plant.value.photos.append(photo)
                }
            }

            photosToDelete.forEach { photo in
                try? realm.write {
                    realm.delete(photo)
                }
            }
        }
    }
}
