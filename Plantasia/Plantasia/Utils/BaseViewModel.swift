//
//  BaseViewModel.swift
//  Plantasia
//
//  Created by bogdan razvan on 26/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Bond

protocol BaseViewModel {

    // MARK: - Properties
    var error: Observable<GeneralError?> { get }

}
