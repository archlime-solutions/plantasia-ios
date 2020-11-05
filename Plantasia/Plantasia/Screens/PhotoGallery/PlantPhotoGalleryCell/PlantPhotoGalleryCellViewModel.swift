//
//  PlantPhotoGalleryCellViewModel.swift
//  Plantasia
//
//  Created by bogdan razvan on 30/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit

class PlantPhotoGalleryCellViewModel {

    // MARK: - Properties
    var plantPhoto: PlantPhoto
    var index: Int
    var isInEditingMode: Bool

    // MARK: - Lifecycle
    init(plantPhoto: PlantPhoto, index: Int, isInEditingMode: Bool) {
        self.plantPhoto = plantPhoto
        self.index = index
        self.isInEditingMode = isInEditingMode
    }

}
