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
        case didSavePlant
    }

    enum CurrentPickerSelection {
        case watering
        case fertilizing
    }

    var error = Observable<GeneralError?>(nil)
    var event = Observable<Event?>(nil)
    //TODO: isRequestInProgress is not used
    var isRequestInProgress = Observable<Bool>(false)
    var name = Observable<String?>(nil)
    var description = Observable<String?>(nil)
    var descriptionPlaceholder = "Description"
    //TODO: check the internet on how often do people water and fertilize their plants
    var watering = Observable<Int>(2)
    var fertilizing = Observable<Int>(14)
    var currentPickerSelection: CurrentPickerSelection?
    var pickerOptions: [Int] = Array(1...31)
    var plantImage: UIImage?
    var placeholderTextColor = UIColor.greyC4C4C4
    var inputTextColor = UIColor.black

    func saveValidatedPlant() {
        if isInputDataComplete() {
            isRequestInProgress.value = true
            let plant = Plant(name: name.value,
                              descr: description.value,
                              wateringFrequencyDays: watering.value,
                              fertilizingFrequencyDays: fertilizing.value,
                              image: plantImage,
                              lastWateringDate: Date(),
                              lastFertilizingDate: Date())
            savePlant(plant) {
                self.isRequestInProgress.value = false
                self.event.value = .didSavePlant
            }
        } else {
            error.value = GeneralError(title: "Missing information", message: "Please take an image of your plant and give it a name.")
        }

    }

    private func isInputDataComplete() -> Bool {
        return name.value != nil && plantImage != nil
    }

    private func savePlant(_ plant: Plant, completion: (() -> Void)?) {
        if let realm = try? Realm() {
            try? realm.write {
                plant.index = realm.objects(Plant.self).count
                realm.add(plant)
                completion?()
            }
        }
    }

}
