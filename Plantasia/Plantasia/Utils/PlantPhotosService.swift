//
//  PlantPhotoService.swift
//  Plantasia
//
//  Created by bogdan razvan on 10/11/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import RealmSwift

class PlantPhotosService {

    /// Updates the description of a plant photo.
    /// - Parameters:
    ///   - plantPhoto: the plant photo.
    ///   - newDescription: the new description of the given plant photo.
    /// - Throws: db error.
    func update(_ plantPhoto: PlantPhoto, newDescription: String?) throws {
        let realm = try Realm()
        try realm.write {
            plantPhoto.descr = newDescription
        }
    }

    /// Creates a plant photo for a plant.
    /// - Parameters:
    ///   - index: the index of the plant photo.
    ///   - image: the image of the plant photo.
    ///   - description: the description of the plant photo.
    ///   - plant: the plant for which to create the plant photo.
    /// - Throws: db error.
    func createPlantPhoto(index: Int, image: UIImage, description: String?, forPlant plant: Plant) throws {
        let realm = try Realm()
        try realm.write {
            let plantPhoto = PlantPhoto(image: image)
            plantPhoto.index = index
            plantPhoto.descr = description
            realm.add(plantPhoto)
            plant.photos.append(plantPhoto)
            realm.add(plant, update: .modified)
        }
    }

    /// Sets the given photos for the given plant.
    /// - Parameters:
    ///   - photos: the photos to set.
    ///   - plant: the plant for which to set the photos.
    /// - Throws: db error.
    func setPhotos(_ photos: [PlantPhoto], forPlant plant: Plant) throws {
        let realm = try Realm()
        let existingPhotosSet = Set(plant.photos)
        let newPhotosSet = Set(photos)
        let photosToDelete = existingPhotosSet.subtracting(newPhotosSet)
        let photosToAdd = newPhotosSet.subtracting(existingPhotosSet)

        try photosToAdd.forEach { photo in
            try realm.write {
                plant.photos.append(photo)
            }
        }

        try photosToDelete.forEach { photo in
            try realm.write {
                realm.delete(photo)
            }
        }
    }

    /// Returns the photos for a plant given its id.
    /// - Parameter plantId: the id of the plant.
    /// - Throws: db error.
    /// - Returns: the array of photos.
    func getPhotosForPlant(withId plantId: Int) throws -> [PlantPhoto] {
        let realm = try Realm()
        return realm.object(ofType: Plant.self, forPrimaryKey: plantId)?.photos.sorted(by: { $0.index < $1.index }) ?? []
    }

    /// Moves a photo from a position to another.
    /// - Parameters:
    ///   - photo: the photo to be moved.
    ///   - fromPosition: the origin position.
    ///   - toPosition: the destination position.
    ///   - plantId: the id of the plant the photo belongs to.
    /// - Throws: db error.
    /// - Returns: the sorted array of plant photos.
    func move(_ photo: PlantPhoto, fromPosition: Int, toPosition: Int, plantId: Int) throws -> [PlantPhoto] {
        let realm = try Realm()
        var photos = try getPhotosForPlant(withId: plantId)
        photos.remove(at: fromPosition)
        photos.insert(photo, at: toPosition)
        for (index, photo) in photos.enumerated() {
            try realm.write {
                photo.index = index
            }
        }
        return photos
    }

}
