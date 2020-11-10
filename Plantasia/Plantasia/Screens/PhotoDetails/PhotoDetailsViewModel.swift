//
//  PhotoDetailsViewModel.swift
//  Plantasia
//
//  Created by bogdan razvan on 04/11/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Bond
import FirebaseCrashlytics

class PhotoDetailsViewModel: BaseViewModel {

    enum Event {
        case didAddPhoto
    }

    // MARK: - Properties
    let error = Observable<GeneralError?>(nil)
    let description = Observable<String?>(nil)
    let plantImage = Observable<UIImage?>(nil)
    let event = Observable<Event?>(nil)
    let descriptionPlaceholder = "Notes"
    let placeholderTextColor = UIColor.greyC4C4C4
    let inputTextColor = UIColor.black232323
    private let plant: Plant?
    private let index: Int
    private let editedPlantPhoto: PlantPhoto?
    private let plantPhotosService = PlantPhotosService()

    // MARK: - Lifecycle
    init(plant: Plant?, editedPlantPhoto: PlantPhoto?, image: UIImage?, index: Int) {
        self.plant = plant
        self.editedPlantPhoto = editedPlantPhoto
        if let editedPlantPhoto = editedPlantPhoto {
            plantImage.value = editedPlantPhoto.getImage()
            description.value = editedPlantPhoto.descr
        } else {
            plantImage.value = image
        }
        self.index = index
    }

    // MARK: - Internal
    func saveValidatedPlantPhoto() {
        if isInputDataComplete() {
            editedPlantPhoto != nil ? updatePlantPhoto() : createPlantPhoto()
            event.value = .didAddPhoto
        } else {
            error.value = GeneralError(title: "Missing information", message: "Please take an image of your plant and give it a name.")
        }
    }

    // MARK: - Private
    private func createPlantPhoto() {
        guard let plant = plant, let image = plantImage.value else { return }
        do {
            try plantPhotosService.createPlantPhoto(index: index, image: image, description: description.value, forPlant: plant)
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
        }
    }

    private func updatePlantPhoto() {
        guard let editedPlantPhoto = editedPlantPhoto else { return }
        do {
            try plantPhotosService.update(editedPlantPhoto, newDescription: description.value)
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
        }
    }

    private func isInputDataComplete() -> Bool {
        return plantImage.value != nil
    }

}
