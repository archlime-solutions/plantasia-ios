//
//  GeneralError.swift
//  Plantasia
//
//  Created by bogdan razvan on 25/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Foundation

class GeneralError: Error {

    var title: String = ""
    var message: String = ""

    init(title: String, message: String) {
        self.title = title
        self.message = message
    }

}
