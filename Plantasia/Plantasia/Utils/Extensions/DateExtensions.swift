//
//  DateExtensions.swift
//  Plantasia
//
//  Created by bogdan razvan on 28/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Foundation

extension Date {

    func toString() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSZ"
        return dateFormatter.string(from: self)
    }

    static func fromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSZ"
        return dateFormatter.date(from: dateString)
    }

    func toHoursMinutesString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }

}
