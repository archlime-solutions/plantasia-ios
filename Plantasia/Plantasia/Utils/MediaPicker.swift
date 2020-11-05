//
//  MediaPicker.swift
//  Plantasia
//
//  Created by bogdan razvan on 25/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit

class MediaPicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Properties
    var picker = UIImagePickerController()
    var alert: UIAlertController?
    var viewController: UIViewController?
    var pickImageCallback: ((UIImage) -> Void)?

    // MARK: - Media picking
    func pickImage(_ viewController: UIViewController, view: UIView,
                   _ callback: @escaping ((UIImage) -> Void)) {
        pickImageCallback = callback
        self.viewController = viewController

        let alert = UIAlertController(title: "Add a Photo",
                                      message: nil,
                                      preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "Camera",
                                         style: .default) { _ in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Library",
                                          style: .default) { _ in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)

        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.permittedArrowDirections = .any
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)

        viewController.present(alert, animated: true, completion: nil)
        self.alert = alert
    }

    func openCamera() {
        alert = nil
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            viewController?.present(picker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Warning",
                                          message: "Camera is not available",
                                          preferredStyle: .alert)

            let cancelAction = UIAlertAction(title: "OK",
                                             style: .default)
            alert.addAction(cancelAction)
            viewController?.present(alert,
                                    animated: true,
                                    completion: nil)
        }
    }

    func openGallery() {
        alert = nil
        picker.sourceType = .photoLibrary
        viewController?.present(picker,
                                animated: true,
                                completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        pickImageCallback?(image)
    }
}
