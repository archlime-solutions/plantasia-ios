//
//  GardenViewModel.swift
//  Plantasia
//
//  Created by bogdan razvan on 26/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Bond
import FirebaseCrashlytics

class GardenViewModel: BaseViewModel, EventTransmitter {

    enum Event {
        case didLoadPlants
        case didWaterPlants
        case didFertilizePlants
    }

    enum SortingCriteria {
        case hydration
        case fertilization
        case ownedSince
    }

    // MARK: - Properties
    let error = Observable<GeneralError?>(nil)
    let event = Observable<Event?>(nil)
    var plants = [Plant]()
    var selectedPlant: Plant?
    var sortingCriteria: SortingCriteria = .ownedSince {
        didSet {
            switch sortingCriteria {
            case .hydration:
                sortByHydration()
            case .fertilization:
                sortByFertilization()
            case .ownedSince:
                sortByOwnedSince()
            }
        }
    }
    private var plantsService = PlantsService()

    // MARK: - Internal
    func loadPlants() {
        do {
            plants = try plantsService.getSortedPlants()
            event.value = .didLoadPlants
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
            self.error.value = GeneralError(title: "Could not load your plants", message: "Please try restarting the application.")
        }
    }

    func movePlant(_ plant: Plant, fromPosition: Int, toPosition: Int) {
        do {
            plants = try plantsService.move(plant, fromPosition: fromPosition, toPosition: toPosition)
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
        }
    }

    func waterAllPlants() {
        do {
            try plantsService.waterAllPlants()
            event.value = .didWaterPlants
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
        }
    }

    func waterDehydratedPlants() {
        do {
            try plantsService.waterDehydratedPlants()
            event.value = .didWaterPlants
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
        }
    }

    func fertilizeAllPlants() {
        do {
            try plantsService.fertilizeAllPlants()
            event.value = .didFertilizePlants
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
        }
    }

    func fertilizeUnfertilizedPlants() {
        do {
            try plantsService.fertilizeUnfertilizedPlants()
            event.value = .didFertilizePlants
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
        }
    }

    private func sortByHydration() {
        do {
            plants = try plantsService.sortByHydration()
            event.value = .didLoadPlants
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
        }
    }

    // MARK: - Private
    private func sortByFertilization() {
        do {
            plants = try plantsService.sortByFertilization()
            event.value = .didLoadPlants
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
        }
    }

    private func sortByOwnedSince() {
        do {
            plants = try plantsService.sortByOwnedSince()
            event.value = .didLoadPlants
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
        }
    }

}
