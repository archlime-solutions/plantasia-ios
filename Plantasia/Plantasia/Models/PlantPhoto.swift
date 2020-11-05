//
//  PlantPhoto.swift
//  Plantasia
//
//  Created by bogdan razvan on 30/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import RealmSwift

class PlantPhoto: Object {

    // MARK: - Properties
    @objc dynamic var creationDate: Date?
    @objc dynamic var photoUUID: String?
    @objc dynamic var index: Int = 0
    @objc dynamic var descr: String?
    private var image: UIImage?

    // MARK: - Lifecycle
    convenience init (
        image: UIImage?
    ) {
        self.init()
        self.creationDate = Date()
        setImage(image)
    }

    // MARK: - Overrides
    override static func primaryKey() -> String? {
        return "photoUUID"
    }

    // MARK: - Internal
    func getImage() -> UIImage? {
        if let image = image {
            return image
        } else {
            loadImage()
            return image
        }
    }

    // MARK: - Private
    private func loadImage() {
        guard let photoUUID = photoUUID,
            let filePath = imageFilePath(imageUUID: photoUUID),
            let fileData = FileManager.default.contents(atPath: filePath.path),
            let image = UIImage(data: fileData)
            else { return }
        self.image = image
    }

    private func setImage(_ image: UIImage?) {
        guard let photo = image?.fixOrientation(),
            let jpegRepresentation = photo.jpegData(compressionQuality: 0.01) else { return }
        let uuid = UUID().uuidString
        if let filePath = imageFilePath(imageUUID: uuid) {
            photoUUID = uuid
            try? jpegRepresentation.write(to: filePath,
                                          options: .atomic)
        }
    }

    private func imageFilePath(imageUUID: String) -> URL? {
        guard let documentURL = FileManager.default.urls(for: .documentDirectory,
                                                         in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
        return documentURL.appendingPathComponent(imageUUID + ".png")
    }

}

// MARK: - NSItemProviderWriting
extension PlantPhoto: NSItemProviderWriting {
    static var writableTypeIdentifiersForItemProvider: [String] {
        return []
    }

    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        return nil
    }
}
