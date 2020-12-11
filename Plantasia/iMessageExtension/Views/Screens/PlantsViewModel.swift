//
//  PlantsViewModel.swift
//  Plantasia
//
//  Created by bogdan razvan on 09/11/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Bond
import FirebaseCrashlytics

class PlantsViewModel {

    enum Event {
        case didLoadPlants(success: Bool)
    }

    // MARK: - Properties
    let event = Observable<Event?>(nil)
    var plants: [Plant] = []
    private let plantsService = PlantsService()

    // MARK: - Lifecycle
    init() {
        DatabaseConfigurator.shared.start()
    }

    // MARK: - Internal
    func loadPlants() {
        do {
            plants = try plantsService.getSortedPlants().filter { $0.getImage() != nil }
            event.value = .didLoadPlants(success: true)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            event.value = .didLoadPlants(success: false)
        }
    }

}
