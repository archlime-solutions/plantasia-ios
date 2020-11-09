//
//  PlantsViewModel.swift
//  Plantasia
//
//  Created by bogdan razvan on 09/11/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Foundation
import Bond
import RealmSwift

class PlantsViewModel {

    enum Event {
        case didLoadPlants(success: Bool)
    }

    // MARK: - Properties
    let event = Observable<Event?>(nil)
    var plants: [Plant] = []

    init() {
        setupDBConnection()
    }

    // MARK: - Internal
    func loadPlants() {
        do {
            let realm = try Realm()
            plants = Array(realm.objects(Plant.self).sorted(by: { $0.index < $1.index })).filter { $0.getImage() != nil }
            event.value = .didLoadPlants(success: true)
        } catch {
            event.value = .didLoadPlants(success: false)
        }
    }

// MARK: - Private
    private func setupDBConnection() {
        var config = Realm.Configuration(
            schemaVersion: Constants.realmDBVersion,
            migrationBlock: nil)

        if let sharedDirectory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.applicationGroup) {
            let sharedRealmURL = sharedDirectory.appendingPathComponent(Constants.sharedRealmUrl)
            config.fileURL = sharedRealmURL
        }

        Realm.Configuration.defaultConfiguration = config
    }

}
