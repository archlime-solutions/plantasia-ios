//
//  PhotoDetailsViewController.swift
//  Plantasia
//
//  Created by bogdan razvan on 04/11/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit
import DTPhotoViewerController

protocol PhotoDetailsViewControllerDelegate: class {
    func photoDetailsViewControllerDidAddPhoto()
}

class PhotoDetailsViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageTopGradientView: UIView!
    @IBOutlet weak var imageShadowContainerView: UIView!
    @IBOutlet weak var imageRoundedContainerView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var doneButton: UIButton!

    var viewModel: PhotoDetailsViewModel!
    weak var delegate: PhotoDetailsViewControllerDelegate?
    private var gradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupDescriptionTextView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = imageTopGradientView.bounds
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        viewModel.saveValidatedPlantPhoto()
    }

    private func setupUI() {
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewPressed)))
        setupImageTopGradientView()
        setupImageRounderContainerView()
        setupImageShadowContainerView()
        setupDoneButton()
        setupNavigationBar()
    }

    private func setupBindings() {
        viewModel.description.bidirectionalBind(to: descriptionTextView.reactive.text).dispose(in: bag)

        viewModel.event.observeNext { [weak self] event in
            guard let self = self, let event = event else { return }
            switch event {
            case .didAddPhoto:
                self.delegate?.photoDetailsViewControllerDidAddPhoto()
                self.navigationController?.popViewController(animated: true)
            }
        }.dispose(in: bag)

        viewModel.plantImage.observeNext { [weak self] value in
            guard let self = self else { return }
            if let value = value {
                self.imageView.image = value
                self.imageView.contentMode = .scaleAspectFill
            } else {
                self.imageView.image = #imageLiteral(resourceName: "camera")
                self.imageView.contentMode = .center
            }
        }.dispose(in: bag)
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .white
    }

    @objc
    private func imageViewPressed(_ sender: UITapGestureRecognizer) {
        let viewController = DTPhotoViewerController(referencedView: imageView, image: viewModel.plantImage.value)
        present(viewController, animated: true, completion: nil)
    }

    private func setupImageTopGradientView() {
        gradientLayer = CAGradientLayer()
        guard let gradientLayer = gradientLayer else { return }
        gradientLayer.frame = imageTopGradientView.bounds
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.clear.cgColor]
        imageTopGradientView.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupImageRounderContainerView() {
        imageRoundedContainerView.layer.cornerRadius = 10
        imageRoundedContainerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }

    private func setupImageShadowContainerView() {
        imageShadowContainerView.layer.shadowRadius = 5
        imageShadowContainerView.layer.shadowColor = UIColor.black.cgColor
        imageShadowContainerView.layer.shadowOpacity = 0.4
        imageShadowContainerView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
    }

    private func setupDoneButton() {
        doneButton.layer.cornerRadius = 10
        doneButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }

    private func setupDescriptionTextView() {
        descriptionTextView.textColor = (viewModel.description.value ?? "").isEmpty ? viewModel.placeholderTextColor : viewModel.inputTextColor
        descriptionTextView.text = (viewModel.description.value ?? "").isEmpty ? viewModel.descriptionPlaceholder : viewModel.description.value
    }

}

// MARK: - UITextViewDelegate
extension PhotoDetailsViewController: UITextViewDelegate {

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = viewModel.placeholderTextColor
            textView.text = viewModel.descriptionPlaceholder
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = viewModel.inputTextColor
        if textView.text == viewModel.descriptionPlaceholder {
            textView.text = nil
        }
    }

}
