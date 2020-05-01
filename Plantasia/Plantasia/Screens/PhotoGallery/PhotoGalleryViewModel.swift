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

    var error = Observable<GeneralError?>(nil)
    var plantName: String?
    var photos: [PlantPhoto]

    init(plantName: String?, photos: [PlantPhoto]) {
        self.plantName = plantName
        self.photos = Array(photos.sorted(by: { $0.index < $1.index }))
    }

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

    func addPhoto(_ image: UIImage) {
        if let realm = try? Realm() {
            try? realm.write {
                let plantPhoto = PlantPhoto(image: image)
                plantPhoto.index = photos.count
                realm.add(plantPhoto)
                photos.append(plantPhoto)
            }
        }
    }

}
