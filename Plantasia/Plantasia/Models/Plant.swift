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
    dynamic var wateringFrequencyDays = RealmOptional<Int>()
    dynamic var fertilizingFrequencyDays = RealmOptional<Int>()
    @objc dynamic var photoUUID: String?
    @objc dynamic var lastWateringDate: Date?
    @objc dynamic var lastFertilizingDate: Date?
    @objc dynamic var index: Int = 0
    private var image: UIImage?
    private var thumbnailImage: UIImage?

    convenience init (
        name: String?,
        descr: String?,
        wateringFrequencyDays: Int?,
        fertilizingFrequencyDays: Int?,
        image: UIImage?,
        lastWateringDate: Date?,
        lastFertilizingDate: Date?
    ) {
        self.init()
        self.id = nextId()
        self.name = name
        self.descr = descr
        self.wateringFrequencyDays.value = wateringFrequencyDays
        self.fertilizingFrequencyDays.value = fertilizingFrequencyDays
        setImage(image)
        self.lastWateringDate = lastWateringDate
        self.lastFertilizingDate = lastFertilizingDate
    }

    override static func primaryKey() -> String? {
        return "id"
    }

    func getWateringPercentage() -> Int {
        guard let lastWateringDate = lastWateringDate,
            let wateringFrequencyDays = wateringFrequencyDays.value,
            let endDate = Calendar.current.date(byAdding: .day, value: wateringFrequencyDays, to: lastWateringDate) else { return 100 }
        let duration = endDate.timeIntervalSince(lastWateringDate)
        let timePassed = Date().timeIntervalSince(lastWateringDate)
        let percent = (duration - timePassed) / duration * 100

        return Int(percent.rounded(.up))
    }

    func getFertilizingPercentage() -> Int {
        guard let lastFertilizingDate = lastFertilizingDate,
            let fertilizingFrequencyDays = fertilizingFrequencyDays.value,
            let endDate = Calendar.current.date(byAdding: .day, value: fertilizingFrequencyDays, to: lastFertilizingDate) else { return 100 }
        let duration = endDate.timeIntervalSince(lastFertilizingDate)
        let timePassed = Date().timeIntervalSince(lastFertilizingDate)
        let percent = (duration - timePassed) / duration * 100

        return Int(percent.rounded(.up))
    }

    func getWateringRemainingDays() -> Int {
        guard let lastWateringDate = lastWateringDate,
            let wateringFrequencyDays = wateringFrequencyDays.value,
            let wateringDate = Calendar.current.date(byAdding: .day, value: wateringFrequencyDays, to: lastWateringDate)
            else { return 0 }
        let calendar = Calendar.current
        let wateringDay = calendar.startOfDay(for: wateringDate)
        let currentDay = calendar.startOfDay(for: Date())

        if let result = calendar.dateComponents([.day], from: currentDay, to: wateringDay).day, result >= 0 {
            return result
        } else {
            return 0
        }
    }

    func getFertilizingRemainingDays() -> Int {
        guard let lastFertilizingDate = lastFertilizingDate,
            let fertilizingFrequencyDays = fertilizingFrequencyDays.value,
            let fertilizingDate = Calendar.current.date(byAdding: .day, value: fertilizingFrequencyDays, to: lastFertilizingDate)
            else { return 0 }
        let calendar = Calendar.current
        let fertilizingDay = calendar.startOfDay(for: fertilizingDate)
        let currentDay = calendar.startOfDay(for: Date())

        if let result = calendar.dateComponents([.day], from: currentDay, to: fertilizingDay).day, result >= 0 {
            return result
        } else {
            return 0
        }
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

    func getImage() -> UIImage? {
        if let image = image {
            return image
        } else {
            return loadImage()
        }
    }

    func setImage(_ image: UIImage?) {
        guard let photo = image?.fixOrientation(),
            let pngRepresentation = photo.pngData(),
            case let uuidString = UUID().uuidString else { return }
        photoUUID = uuidString
        if let filePath = imageFilePath() {
            try? pngRepresentation.write(to: filePath,
                                         options: .atomic)
        }
    }

    func getThumbnailImage() -> UIImage? {
        if let image = thumbnailImage {
            return image
        } else {
            loadImage()
            return thumbnailImage
        }
    }

    @discardableResult
    func loadImage() -> UIImage? {
        guard let filePath = imageFilePath(),
            let fileData = FileManager.default.contents(atPath: filePath.path),
            let image = UIImage(data: fileData)
            else { return nil }
        self.image = image

        if let lowQualityData = image.jpegData(compressionQuality: 0.1),
            let thumbnailImage = UIImage(data: lowQualityData) {
            self.thumbnailImage = thumbnailImage
        }

        return self.image
    }

    private func imageFilePath() -> URL? {
        guard let photoUUID = self.photoUUID,
            let documentURL = FileManager.default.urls(for: .documentDirectory,
                                                       in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
        return documentURL.appendingPathComponent(photoUUID + ".png")
    }

}

extension Plant: NSItemProviderWriting {
    static var writableTypeIdentifiersForItemProvider: [String] {
        return []
    }

    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        return nil
    }
}
