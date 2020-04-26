//
//  Plant.swift
//  Plantasia
//
//  Created by bogdan razvan on 25/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import Foundation
import RealmSwift

class Plant: Object {

    @objc dynamic var id: Int = -1
    @objc dynamic var name: String?
    @objc dynamic var descr: String?
    dynamic var watering = RealmOptional<Int>()
    dynamic var fertilizing = RealmOptional<Int>()
    @objc dynamic var photoPath: String?
    var image: UIImage? {
        get {
            guard let photoPath = photoPath else { return nil }
            let image = UIImage(contentsOfFile: photoPath as String)
            return image
        }
        set {
            guard let photo = newValue else { return }
            photoPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("plant")
            FileManager.default.createFile(atPath: photoPath! as String, contents: photo.pngData(), attributes: nil)
        }
    }

    convenience init (
        name: String?,
        descr: String?,
        watering: Int?,
        fertilizing: Int?,
        image: UIImage?
    ) {
        self.init()
        self.id = nextId()
        self.name = name
        self.descr = descr
        self.watering.value = watering
        self.fertilizing.value = fertilizing
        self.image = image
    }

    //TODO razvan: ceva cu original image in loc de edited din picker

    override static func primaryKey() -> String? {
        return "id"
    }

    func nextId() -> Int {
        if let realm = try? Realm() {
            if let retNext = realm.objects(Plant.self).sorted(byKeyPath: "id", ascending: false).first?.id {
                return retNext + 1
            } else {
                return 1
            }
        } else {
            return -1
        }
    }

}
