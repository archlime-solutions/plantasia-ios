//
//  PhotoGalleryViewModel.swift
//  Plantasia
//
//  Created by bogdan razvan on 30/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Bond
import FirebaseCrashlytics

class PhotoGalleryViewModel: BaseViewModel {

    enum Event {
        case didLoadPlantPhotos
    }

    // MARK: - Properties
    let error = Observable<GeneralError?>(nil)
    let event = Observable<Event?>(nil)
    var plantName: String?
    var photos: [PlantPhoto]
    var selectedPlantPhoto: PlantPhoto?
    var selectedImage: UIImage?
    var plant: Plant
    private var plantId: Int?
    private let plantPhotosService = PlantPhotosService()

    // MARK: - Lifecycle
    init(plant: Plant, photos: [PlantPhoto]) {
        self.plant = plant
        self.plantName = plant.name
        self.plantId = plant.id
        self.photos = photos
        getPlantPhotos()
    }

    // MARK: - Internal
    func movePhoto(_ photo: PlantPhoto, fromPosition: Int, toPosition: Int) {
        guard let plantId = plantId else { return }
//        photos.remove(at: fromPosition)
//        photos.insert(photo, at: toPosition)

        do {
            photos = try plantPhotosService.move(photo, fromPosition: fromPosition, toPosition: toPosition, plantId: plantId)
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
        }
    }

    func getPlantPhotos() {
        guard let plantId = plantId else { return }
        do {
            try self.photos = plantPhotosService.getPhotosForPlant(withId: plantId)
            event.value = .didLoadPlantPhotos
        } catch let error {
            Crashlytics.crashlytics().record(error: error)
            self.error.value = GeneralError(title: "Could not load your photos", message: "Please try again.")
        }
    }

}
