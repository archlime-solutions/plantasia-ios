//
//  PhotoGalleryViewModel.swift
//  Plantasia
//
//  Created by bogdan razvan on 30/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Bond

class PhotoGalleryViewModel: BaseViewModel {

    var error = Observable<GeneralError?>(nil)
    var plantName: String?
    var photos: [PlantPhoto]

    init(plantName: String?, photos: [PlantPhoto]) {
        self.plantName = plantName
        self.photos = photos
    }

}
