//
//  PlantDetailsViewModel.swift
//  Plantasia
//
//  Created by bogdan razvan on 27/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Bond
import FirebaseCrashlytics

class PlantDetailsViewModel: BaseViewModel, EventTransmitter {

    enum Event {
        case didWaterPlant
        case didFertilizePlant
    }

    // MARK: - Properties
    var error = Observable<GeneralError?>(nil)
    var event = Observable<Event?>(nil)
    var plant: Observable<Plant>
    private let plantsService = PlantsService()
    private let plantPhotosService = PlantPhotosService()

    // MARK: - Lifecycle
    init(plant: Plant) {
        self.plant = Observable<Plant>(plant)
    }

    // MARK: - Internal
    func waterPlant() {
        do {
            try plantsService.water(plant.value)
            event.value = .didWaterPlant
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
        }
    }

    func fertilizePlant() {
        do {
            try plantsService.fertilize(plant.value)
            event.value = .didFertilizePlant
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
        }
    }

    func setPhotos(_ photos: [PlantPhoto]) {
        do {
            try plantPhotosService.setPhotos(photos, forPlant: plant.value)
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
        }
    }
}
