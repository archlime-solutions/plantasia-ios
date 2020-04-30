//
//  PlantPhotoGalleryCellViewModel.swift
//  Plantasia
//
//  Created by bogdan razvan on 30/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit

class PlantPhotoGalleryCellViewModel {

    var plantPhoto: PlantPhoto
    var index: Int
    var isInEditingMode: Bool

    init(plantPhoto: PlantPhoto, index: Int, isInEditingMode: Bool) {
        self.plantPhoto = plantPhoto
        self.index = index
        self.isInEditingMode = isInEditingMode
    }

}
