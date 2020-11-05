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

    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageTopGradientView: UIView!
    @IBOutlet weak var imageShadowContainerView: UIView!
    @IBOutlet weak var imageRoundedCornersContainerView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var wateringTextField: UITextField!
    @IBOutlet weak var fertilizingTextField: UITextField!
    @IBOutlet weak var deletePlantButton: UIButton!
    @IBOutlet weak var ownedSinceStackView: UIStackView!
    @IBOutlet weak var ownedSinceTextField: CustomTextField!
    @IBOutlet weak var doneButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneButtonTopConstraint: NSLayoutConstraint!

    // MARK: - Properties
    var viewModel: AddPlantViewModel!
    weak var delegate: AddPlantViewControllerDelegate?
    private var gradientLayer: CAGradientLayer?
    private var mediaPicker = MediaPicker()
    private var daysPicker = UIPickerView()
    private var ownedSincePicker = UIDatePicker()

    // MARK: - Lifecycle
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, animations: {
            self.showDoneButton()
        })
    }

    // MARK: - Overrides
    override func keyboardChanged(height: CGFloat) {
        scrollView.contentInset.bottom = height == 0 ? 104 : height
    }

    // MARK: - IBActions
    @IBAction func doneButtonPressed(_ sender: Any) {
        viewModel.saveValidatedPlant()
    }

    @IBAction func deleteButtonPressed(_ sender: Any) {
        let handler: () -> Void = {
            self.viewModel.deletePlant()
        }
        showAlert(title: "Are you sure you want to remove this plant?",
                  message: "Removing this plant will also remove its photo album.",
                  buttonText: "Remove",
                  buttonHandler: handler,
                  buttonStyle: .destructive,
                  showCancelButton: true)
    }

    // MARK: - Private
    private func setupBindings() {
        viewModel.name.bidirectionalBind(to: nameTextField.reactive.text).dispose(in: bag)
        viewModel.description.bidirectionalBind(to: descriptionTextView.reactive.text).dispose(in: bag)
        bindWatering()
        bindFertilizing()
        bindOwnedSince()
        bindPlantImage()
        bindEvent()
        bindError()
    }

    private func bindWatering() {
        viewModel.watering.observeNext { [weak self] value in
            guard let self = self else { return }
            self.wateringTextField.text = "Watering every \(value) \(value > 1 ? "days" : "day")"
        }.dispose(in: bag)
    }

    private func bindFertilizing() {
        viewModel.fertilizing.observeNext { [weak self] value in
            guard let self = self else { return }
            self.fertilizingTextField.text = "Fertilizing every \(value) \(value > 1 ? "days" : "day")"
        }.dispose(in: bag)
    }

    private func bindOwnedSince() {
        viewModel.ownedSince.observeNext { [weak self] value in
            guard let self = self, let ownedSinceValue = value?.toShortMonthYearString() else { return }
            self.ownedSinceTextField.text = "Owned since \(ownedSinceValue)"
        }.dispose(in: bag)
    }

    private func bindPlantImage() {
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

    private func bindEvent() {
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
    }

    private func bindError() {
        viewModel.error.observeNext { [weak self] value in
            guard let self = self, let value = value else { return }
            self.showAlert(error: value)
        }.dispose(in: bag)
    }

    private func setupUI() {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 104, right: 0)
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewPressed)))
        setupImageTopGradientView()
        setupImageRounderCornersContainerView()
        setupImageShadowContainerView()
        setupDoneButton()
        setupDeletePlantButton()
        setupDaysPicker()
        setupOwnedSincePicker()
        setupCancelBarButtonItem()
        setupNavigationBar()
        hideDoneButton()
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.isTranslucent = true
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

    private func pickerToolbar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black232323
        toolBar.barTintColor = .whiteFFFFFF
        toolBar.sizeToFit()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pickerDoneButtonTapped))
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        return toolBar
    }

    private func setupDaysPicker() {
        daysPicker.delegate = self
        daysPicker.backgroundColor = .whiteFFFFFF
        wateringTextField.inputView = daysPicker
        fertilizingTextField.inputView = daysPicker
        wateringTextField.inputAccessoryView = pickerToolbar()
        fertilizingTextField.inputAccessoryView = pickerToolbar()
    }

    private func setupOwnedSincePicker() {
        if viewModel.isEditingExistingPlant {
            ownedSinceStackView.isHidden = false
            ownedSincePicker.datePickerMode = .date
            ownedSincePicker.maximumDate = Date()
            ownedSincePicker.backgroundColor = .whiteFFFFFF
            ownedSinceTextField.inputView = ownedSincePicker
            ownedSinceTextField.inputAccessoryView = pickerToolbar()
            ownedSincePicker.addTarget(self, action: #selector(ownedSincePickerValueChanged), for: .valueChanged)
        } else {
            ownedSinceStackView.isHidden = true
        }
    }

    @objc
    private func ownedSincePickerValueChanged(_ datePicker: UIDatePicker) {
        viewModel.ownedSince.value = datePicker.date
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

    private func hideDoneButton() {
        doneButtonBottomConstraint.constant = -104
        doneButtonTopConstraint.constant = 0
        view.layoutIfNeeded()
    }

    private func showDoneButton() {
        doneButtonBottomConstraint.constant = 0
        doneButtonTopConstraint.constant = 104
        view.layoutIfNeeded()
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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentString = textField.text as NSString? else { return true }
        let newString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= 15
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

}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension AddPlantViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.daysPickerOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let option = viewModel.daysPickerOptions[row]
        return "\(option) \(option > 1 ? "days" : "day")"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let currentPickerSelection = viewModel.currentPickerSelection else { return }
        let numberOfDays = viewModel.daysPickerOptions[row]
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
