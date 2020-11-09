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

    // MARK: - Properties
    private static let criticalPercentageThreshold = 10

    @objc dynamic var id: Int = -1
    @objc dynamic var name: String?
    @objc dynamic var descr: String?
    dynamic var wateringFrequencyDays = RealmOptional<Int>()
    dynamic var fertilizingFrequencyDays = RealmOptional<Int>()
    @objc dynamic var photoUUID: String?
    @objc dynamic var lastWateringDate: Date?
    @objc dynamic var lastFertilizingDate: Date?
    @objc dynamic var index: Int = 0
    @objc dynamic var ownedSinceDate: Date?
    var photos = List<PlantPhoto>()
    private var image: UIImage?

    // MARK: - Lifecycle
    convenience init (
        name: String?,
        descr: String?,
        wateringFrequencyDays: Int?,
        fertilizingFrequencyDays: Int?,
        image: UIImage?,
        lastWateringDate: Date?,
        lastFertilizingDate: Date?,
        photos: [PlantPhoto],
        ownedSinceDate: Date
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
        self.photos.append(objectsIn: photos)
        self.ownedSinceDate = ownedSinceDate
    }

    // MARK: - Overrides
    override static func primaryKey() -> String? {
        return "id"
    }

    // MARK: - Internal
    func requiresAttention() -> Bool {
        return requiresWatering() || requiresFertilizing()
    }

    func requiresWatering() -> Bool {
        return getWateringPercentage() <= Plant.criticalPercentageThreshold
    }

    func requiresFertilizing() -> Bool {
        return getFertilizingPercentage() <= Plant.criticalPercentageThreshold
    }

    func getWateringPercentage() -> Int {
        guard let lastWateringDate = lastWateringDate,
            let wateringFrequencyDays = wateringFrequencyDays.value,
            let endDate = Calendar.current.date(byAdding: .day, value: wateringFrequencyDays, to: lastWateringDate) else { return 100 }
        let duration = endDate.timeIntervalSince(lastWateringDate)
        let timePassed = Date().timeIntervalSince(lastWateringDate)
        let percent = (duration - timePassed) / duration * 100

        let result = Int(percent.rounded(.up))
        if result < 0 {
            return 0
        } else {
            return result
        }
    }

    func getFertilizingPercentage() -> Int {
        guard let lastFertilizingDate = lastFertilizingDate,
            let fertilizingFrequencyDays = fertilizingFrequencyDays.value,
            let endDate = Calendar.current.date(byAdding: .day, value: fertilizingFrequencyDays, to: lastFertilizingDate) else { return 100 }
        let duration = endDate.timeIntervalSince(lastFertilizingDate)
        let timePassed = Date().timeIntervalSince(lastFertilizingDate)
        let percent = (duration - timePassed) / duration * 100

        let result = Int(percent.rounded(.up))
        if result < 0 {
            return 0
        } else {
            return result
        }
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

    func water() {
        lastWateringDate = Date()
    }

    func fertilize() {
        lastFertilizingDate = Date()
    }

    func getImage() -> UIImage? {
        if let image = image {
            return image
        } else {
            loadImage()
            return image
        }
    }

    func setImage(_ image: UIImage?) {
        guard let photo = image?.fixOrientation(),
            let jpegRepresentation = photo.jpegData(compressionQuality: 0.1) else { return }
        let uuid = UUID().uuidString
        if let filePath = imageFilePath(imageUUID: uuid) {
            photoUUID = uuid
            try? jpegRepresentation.write(to: filePath,
                                          options: .atomic)
            loadImage()
        }
    }

    // MARK: - Private
    private func nextId() -> Int {
        if let realm = try? Realm() {
            if let retNext = realm.objects(Plant.self).sorted(byKeyPath: "id", ascending: false).first?.id {
                return retNext + 1
            }
        }
        return -1
    }

    private func loadImage() {
        guard let photoUUID = photoUUID,
            let filePath = imageFilePath(imageUUID: photoUUID),
            let fileData = FileManager.default.contents(atPath: filePath.path),
            let image = UIImage(data: fileData)
            else { return }
        self.image = image
    }

    private func imageFilePath(imageUUID: String) -> URL? {
        guard let documentURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.applicationGroup) else { return nil }
        return documentURL.appendingPathComponent(imageUUID + ".png")
    }

}

// MARK: - NSItemProviderWriting
extension Plant: NSItemProviderWriting {
    static var writableTypeIdentifiersForItemProvider: [String] {
        return []
    }

    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        return nil
    }
}
