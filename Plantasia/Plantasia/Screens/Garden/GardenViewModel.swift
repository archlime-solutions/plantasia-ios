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
        } catch {
            //TODO: log error
            self.error.value = GeneralError(title: "Could not load your plants", message: "Please try restarting the application.")
        }
    }

    func movePlant(_ plant: Plant, fromPosition: Int, toPosition: Int) {
        do {
            try plantsService.movePlant(fromPosition: fromPosition, toPosition: toPosition)
            plants.remove(at: fromPosition)
            plants.insert(plant, at: toPosition)
        } catch {
            //TODO: log error
        }
    }

    func waterAllPlants() {
        do {
            try plantsService.waterAllPlants()
            event.value = .didWaterPlants
        } catch {
            //TODO: log error
        }
    }

    func waterDehydratedPlants() {
        do {
            try plantsService.waterDehydratedPlants()
            event.value = .didWaterPlants
        } catch {
            //TODO: log error
        }
    }

    func fertilizeAllPlants() {
        do {
            try plantsService.fertilizeAllPlants()
            event.value = .didFertilizePlants
        } catch {
            //TODO: log error
        }
    }

    func fertilizeUnfertilizedPlants() {
        do {
            try plantsService.fertilizeUnfertilizedPlants()
            event.value = .didFertilizePlants
        } catch {
            //TODO: log error
        }
    }

    private func sortByHydration() {
        do {
            plants = try plantsService.sortByHydration()
            event.value = .didLoadPlants
        } catch {
            //TODO: log error
        }
    }

    // MARK: - Private
    private func sortByFertilization() {
        do {
            plants = try plantsService.sortByFertilization()
            event.value = .didLoadPlants
        } catch {
            //TODO: log error
        }
    }

    private func sortByOwnedSince() {
        do {
            plants = try plantsService.sortByOwnedSince()
            event.value = .didLoadPlants
        } catch {
            //TODO: log error
        }
    }

}
