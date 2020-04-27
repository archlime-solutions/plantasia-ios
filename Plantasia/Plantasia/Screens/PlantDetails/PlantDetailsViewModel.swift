//
//  PlantDetailsViewModel.swift
//  Plantasia
//
//  Created by bogdan razvan on 27/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Bond

class PlantDetailsViewModel: BaseViewModel {

    var error = Observable<GeneralError?>(nil)
    var plant: Plant

    init(plant: Plant) {
        self.plant = plant
    }
}
