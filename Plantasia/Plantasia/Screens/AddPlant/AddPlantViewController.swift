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

class AddPlantViewController: BaseViewController, LoadingViewPresenter, AlertPresenter {

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
    @IBOutlet weak var cancelButton: UIButton!

    private let viewModel = AddPlantViewModel()
    private var gradientLayer: CAGradientLayer?
    private var mediaPicker = MediaPicker()
    private var daysPicker = UIPickerView()

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardHeightChangeObservers()
    }

    override func keyboardChanged(height: CGFloat) {
        scrollView.contentInset.bottom = height
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        viewModel.saveValidatedPlant()
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

        viewModel.event.observeNext { [weak self] event in
            if let event = event {
                switch event {
                case .didSavePlant:
                    self?.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        }.dispose(in: bag)

        viewModel.isRequestInProgress.observeNext { [weak self] value in
            guard let self = self else { return }
            value ? self.showLoadingView() : self.hideLoadingView()
        }.dispose(in: bag)

        viewModel.error.observeNext { [weak self] value in
            guard let self = self, let value = value else { return }
            self.hideLoadingView()
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
        setupCancelButton()
        setupDaysPicker()

    }

    private func setupDaysPicker() {
        daysPicker.delegate = self
        wateringTextField.inputView = daysPicker
        fertilizingTextField.inputView = daysPicker

        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black232323
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
            self.imageView.image = image
            self.viewModel.plantImage = image
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
        photoGalleryButton.layer.cornerRadius = 10
        photoGalleryButton.layer.borderWidth = 2
        photoGalleryButton.layer.borderColor = UIColor.green90D599.cgColor
    }

    private func setupDescriptionTextView() {
        descriptionTextView.textColor = (viewModel.description.value ?? "").isEmpty ? viewModel.placeholderTextColor : viewModel.inputTextColor
        descriptionTextView.text = (viewModel.description.value ?? "").isEmpty ? viewModel.descriptionPlaceholder : viewModel.description.value
    }

    private func setupCancelButton() {
        cancelButton.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(10 + (UIApplication.shared.windows.first { $0.isKeyWindow }?.safeAreaInsets.top ?? 0))
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
        if textView.textColor == viewModel.placeholderTextColor {
            textView.text = nil
            textView.textColor = viewModel.inputTextColor
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
        case .watering: viewModel.watering.value = numberOfDays
        case .fertilizing: viewModel.fertilizing.value = numberOfDays
        }
    }

}
