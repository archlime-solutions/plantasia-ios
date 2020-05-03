//
//  AddPlantViewController.swift
//  Plantasia
//
//  Created by bogdan razvan on 25/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift

protocol AddPlantViewControllerDelegate: class {
    func addPlantViewControllerDidCreatePlant()
}

class AddPlantViewController: BaseViewController, AlertPresenter {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageTopGradientView: UIView!
    @IBOutlet weak var imageShadowContainerView: UIView!
    @IBOutlet weak var imageRoundedCornersContainerView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var photoGalleryButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var wateringTextField: UITextField!
    @IBOutlet weak var fertilizingTextField: UITextField!
    @IBOutlet weak var deletePlantButton: UIButton!

    var viewModel: AddPlantViewModel!
    weak var delegate: AddPlantViewControllerDelegate?
    private var gradientLayer: CAGradientLayer?
    private var mediaPicker = MediaPicker()
    private var daysPicker = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupDescriptionTextView()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.isTranslucent = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = imageTopGradientView.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardHeightChangeObservers()
    }

    override func keyboardChanged(height: CGFloat) {
        scrollView.contentInset.bottom = height
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        viewModel.saveValidatedPlant()
    }

    @IBAction func photoGalleryButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: .pushPhotoGallery)
    }

    @IBAction func deleteButtonPressed(_ sender: Any) {
        let handler: () -> Void = {
            self.viewModel.deletePlant()
        }
        showAlert(title: "Are you sure you want to remove this plant?",
                  message: "Removing this plant will also remove its photo gallery.",
                  buttonText: "Remove",
                  buttonHandler: handler,
                  buttonStyle: .destructive,
                  showCancelButton: true)
    }

    private func setupBindings() {
        viewModel.name.bidirectionalBind(to: nameTextField.reactive.text).dispose(in: bag)
        viewModel.description.bidirectionalBind(to: descriptionTextView.reactive.text).dispose(in: bag)

        viewModel.watering.observeNext { [weak self] value in
            guard let self = self else { return }
            self.wateringTextField.text = "Watering every \(value) \(value > 1 ? "days" : "day")"
        }.dispose(in: bag)

        viewModel.fertilizing.observeNext { [weak self] value in
            guard let self = self else { return }
            self.fertilizingTextField.text = "Fertilizing every \(value) \(value > 1 ? "days" : "day")"
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

        viewModel.event.observeNext { [weak self] event in
            guard let self = self, let event = event else { return }
            switch event {
            case .didCreatePlant:
                self.dismiss(animated: true, completion: {
                    self.delegate?.addPlantViewControllerDidCreatePlant()
                })
            case .didUpdatePlant:
                self.navigationController?.popViewController(animated: true)
            case .didRemovePlant:
                guard let gardenViewController = self.navigationController?.viewControllers.first as? GardenViewController else { return }
                gardenViewController.loadPlants()
                self.navigationController?.popToRootViewController(animated: true)
            }
        }.dispose(in: bag)

        viewModel.error.observeNext { [weak self] value in
            guard let self = self, let value = value else { return }
            self.showAlert(error: value)
        }.dispose(in: bag)
    }

    private func setupUI() {
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewPressed)))
        setupImageTopGradientView()
        setupImageRounderCornersContainerView()
        setupImageShadowContainerView()
        setupDoneButton()
        setupPhotoGalleryButton()
        setupDeletePlantButton()
        setupDaysPicker()
        setupCancelBarButtonItem()
    }

    private func setupCancelBarButtonItem() {
        if !viewModel.isEditingExistingPlant {
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonPressed))
            cancelButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white,
                                                 NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)], for: .normal)
            navigationItem.rightBarButtonItem = cancelButton
        }
    }

    @objc
    private func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    private func setupDaysPicker() {
        daysPicker.delegate = self
        daysPicker.backgroundColor = .whiteFFFFFF
        wateringTextField.inputView = daysPicker
        fertilizingTextField.inputView = daysPicker

        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black232323
        toolBar.barTintColor = .whiteFFFFFF
        toolBar.sizeToFit()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.pickerDoneButtonTapped))
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        wateringTextField.inputAccessoryView = toolBar
        fertilizingTextField.inputAccessoryView = toolBar
    }

    @objc
    private func pickerDoneButtonTapped() {
        view.endEditing(true)
    }

    @objc
    private func imageViewPressed(_ sender: UITapGestureRecognizer) {
        mediaPicker.pickImage(self, { image in
            self.viewModel.plantImage.value = image
        })
    }

    private func setupImageTopGradientView() {
        gradientLayer = CAGradientLayer()
        guard let gradientLayer = gradientLayer else { return }
        gradientLayer.frame = imageTopGradientView.bounds
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.clear.cgColor]
        imageTopGradientView.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupImageRounderCornersContainerView() {
        imageRoundedCornersContainerView.layer.cornerRadius = 10
        imageRoundedCornersContainerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
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

    private func setupPhotoGalleryButton() {
        if viewModel.isEditingExistingPlant {
            photoGalleryButton.isHidden = true
        } else {
            photoGalleryButton.layer.cornerRadius = 10
            photoGalleryButton.layer.borderWidth = 2
            photoGalleryButton.layer.borderColor = UIColor.green90D599.cgColor
        }
    }

    private func setupDescriptionTextView() {
        descriptionTextView.textColor = (viewModel.description.value ?? "").isEmpty ? viewModel.placeholderTextColor : viewModel.inputTextColor
        descriptionTextView.text = (viewModel.description.value ?? "").isEmpty ? viewModel.descriptionPlaceholder : viewModel.description.value
    }

    private func setupDeletePlantButton() {
        if viewModel.isEditingExistingPlant {
            deletePlantButton.layer.cornerRadius = 10
            deletePlantButton.layer.borderWidth = 2
            deletePlantButton.layer.borderColor = UIColor.orangeFE865D.cgColor
        } else {
            deletePlantButton.isHidden = true
        }
    }

}

// MARK: - UITextFieldDelegate
extension AddPlantViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == wateringTextField {
            viewModel.currentPickerSelection = .watering
            daysPicker.selectRow(viewModel.watering.value - 1, inComponent: 0, animated: true)
        } else if textField == fertilizingTextField {
            viewModel.currentPickerSelection = .fertilizing
            daysPicker.selectRow(viewModel.fertilizing.value - 1, inComponent: 0, animated: true)
        }
    }

}

// MARK: - UITextViewDelegate
extension AddPlantViewController: UITextViewDelegate {

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

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension AddPlantViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.pickerOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let option = viewModel.pickerOptions[row]
        return "\(option) \(option > 1 ? "days" : "day")"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let currentPickerSelection = viewModel.currentPickerSelection else { return }
        let numberOfDays = viewModel.pickerOptions[row]
        switch currentPickerSelection {
        case .watering:
            viewModel.watering.value = numberOfDays
            wateringTextField.animateScale()
        case .fertilizing:
            viewModel.fertilizing.value = numberOfDays
            fertilizingTextField.animateScale()
        }
    }

}

// MARK: - UIScrollViewDelegate
extension AddPlantViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }

}

// MARK: - SegueHandler
extension AddPlantViewController: SegueHandler {

    enum SegueIdentifier: String {
        case pushPhotoGallery
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .pushPhotoGallery:
            guard let nextVC = segue.destination as? PhotoGalleryViewController else { return }
            nextVC.viewModel = PhotoGalleryViewModel(plantName: nil, photos: viewModel.photos)
            nextVC.delegate = self
        }
    }

}

// MARK: - PhotoGalleryViewControllerDelegate
extension AddPlantViewController: PhotoGalleryViewControllerDelegate {

    func photoGalleryViewControllerDidSavePhotos(_ photos: [PlantPhoto]) {
        viewModel.setPhotos(photos)
    }

}
