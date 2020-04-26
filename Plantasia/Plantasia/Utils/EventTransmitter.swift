//
//  EventTransmitter.swift
//  Plantasia
//
//  Created by bogdan razvan on 26/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Bond

protocol EventTransmitter where Self: BaseViewModel {

    associatedtype Event

    var event: Observable<Event?> { get }

}
