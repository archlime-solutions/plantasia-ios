//
//  AddPlantViewModel.swift
//  Plantasia
//
//  Created by bogdan razvan on 25/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Bond
import RealmSwift

class AddPlantViewModel: BaseViewModel, EventTransmitter {

    enum Event {
        case didCreatePlant
        case didUpdatePlant
        case didRemovePlant
    }

    enum CurrentPickerSelection {
        case watering
        case fertilizing
    }

    // MARK: - Properties
    var error = Observable<GeneralError?>(nil)
    var event = Observable<Event?>(nil)
    var isEditingExistingPlant: Bool {
        get {
            return plant != nil
        }
    }
    var name = Observable<String?>(nil)
    var description = Observable<String?>(nil)
    var descriptionPlaceholder = "Notes"
    var watering = Observable<Int>(2)
    var fertilizing = Observable<Int>(14)
    var ownedSince = Observable<Date?>(nil)
    var currentPickerSelection: CurrentPickerSelection?
    var daysPickerOptions: [Int] = Array(1...31)
    var plantImage = Observable<UIImage?>(nil)
    var photos = [PlantPhoto]()
    var placeholderTextColor = UIColor.greyC4C4C4
    var inputTextColor = UIColor.black232323
    private var plant: Plant?

    // MARK: - Lifecycle
    init(plant: Plant?) {
        self.plant = plant
        if let plant = plant {
            name.value = plant.name
            description.value = plant.descr
            watering.value = plant.wateringFrequencyDays.value ?? 2
            fertilizing.value = plant.fertilizingFrequencyDays.value ?? 14
            ownedSince.value = plant.ownedSinceDate
            plantImage.value = plant.getImage()
        }
    }

    // MARK: - Internal
    func saveValidatedPlant() {
        if isInputDataComplete() {
            if isEditingExistingPlant {
                updatePlant()
                event.value = .didUpdatePlant
            } else {
                let plant = Plant(name: name.value,
                                  descr: description.value,
                                  wateringFrequencyDays: watering.value,
                                  fertilizingFrequencyDays: fertilizing.value,
                                  image: plantImage.value,
                                  lastWateringDate: Date(),
                                  lastFertilizingDate: Date(),
                                  photos: photos,
                                  ownedSinceDate: Date())
                create(plant)
                event.value = .didCreatePlant
            }
            PushNotificationService.shared.requestPushNotificationAuthorization()
        } else {
            error.value = GeneralError(title: "Missing information", message: "Please take an image of your plant and give it a name.")
        }
    }

    func deletePlant() {
        guard let plant = plant else { return }
        if let realm = try? Realm() {
            try? realm.write {
                realm.delete(plant)
                self.event.value = .didRemovePlant
            }
        }
    }

    // MARK: - Private
    private func create(_ plant: Plant) {
        if let realm = try? Realm() {
            try? realm.write {
                plant.index = realm.objects(Plant.self).count
                realm.add(plant)
            }
        }
    }

    private func updatePlant() {
        if let realm = try? Realm() {
            try? realm.write {
                plant?.name = name.value
                plant?.descr = description.value
                plant?.wateringFrequencyDays.value = watering.value
                plant?.fertilizingFrequencyDays.value = fertilizing.value
                plant?.setImage(plantImage.value)
                plant?.ownedSinceDate = ownedSince.value
            }
        }
    }

    private func isInputDataComplete() -> Bool {
        return !(name.value ?? "").isEmpty && plantImage.value != nil
    }

}
