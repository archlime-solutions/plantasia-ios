//
//  PhotoGalleryViewModel.swift
//  Plantasia
//
//  Created by bogdan razvan on 30/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Bond
import RealmSwift

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
    var plant: Plant?
    private var plantId: Int?

    // MARK: - Lifecycle
    init(plant: Plant?, photos: [PlantPhoto]) {
        self.plant = plant
        self.plantName = plant?.name
        self.plantId = plant?.id
        self.photos = photos
        if plantId != nil {
            getPlantPhotos()
        }
    }

    // MARK: - Internal
    func movePhoto(_ photo: PlantPhoto, fromPosition: Int, toPosition: Int) {
        photos.remove(at: fromPosition)
        photos.insert(photo, at: toPosition)

        if let realm = try? Realm() {
            for (index, photo) in photos.enumerated() {
                try? realm.write {
                    photo.index = index
                }
            }
        }
    }

    func getPlantPhotos() {
        if let realm = try? Realm(),
            let photos = realm.object(ofType: Plant.self, forPrimaryKey: plantId)?.photos.sorted(by: { $0.index < $1.index }) {
            self.photos = photos
            event.value = .didLoadPlantPhotos
        } else {
            error.value = GeneralError(title: "Could not load your plants", message: "Please try restarting the application.")
        }
    }

}
