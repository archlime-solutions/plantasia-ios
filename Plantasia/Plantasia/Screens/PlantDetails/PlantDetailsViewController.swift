//
//  PlantDetailsViewController.swift
//  Plantasia
//
//  Created by bogdan razvan on 27/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit

class PlantDetailsViewController: BaseViewController, AlertPresenter {

    @IBOutlet weak var actionBarShadowContainerView: UIView!
    @IBOutlet weak var actionBarRoundedContainerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageTopGradientView: UIView!
    @IBOutlet weak var imageShadowContainerView: UIView!
    @IBOutlet weak var imageRoundedCornersContainerView: UIView!
    @IBOutlet weak var descriptionStackView: UIStackView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var wateringLabel: UILabel!
    @IBOutlet weak var fertilizingLabel: UILabel!
    @IBOutlet weak var wateringPercentageLabel: UILabel!
    @IBOutlet weak var fertilizingPercentageLabel: UILabel!
    @IBOutlet weak var photoGalleryButton: UIButton!

    var viewModel: PlantDetailsViewModel!
    private var gradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .white
        setupPlantData()
        setupNavigationBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = imageTopGradientView.bounds
    }

    @IBAction func waterButtonPressed(_ sender: Any) {
        viewModel.waterPlant()
    }

    @IBAction func fertilizeButtonPressed(_ sender: Any) {
        viewModel.fertilizePlant()
    }

    @IBAction func photoGalleryButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: .pushPhotoGallery)
    }

    private func setupBindings() {
        viewModel.plant.observeNext { [weak self] _ in
            guard let self = self else { return }
            self.setupPlantData()
        }.dispose(in: bag)

        viewModel.event.observeNext { [weak self] value in
            guard let self = self, let value = value else { return }
            switch value {
            case .didFertilizePlant:
                self.setupPlantData()
                self.fertilizingLabel.animateScale()
                self.fertilizingPercentageLabel.animateScale()
            case .didWaterPlant:
                self.setupPlantData()
                self.wateringLabel.animateScale()
                self.wateringPercentageLabel.animateScale()
            }
        }.dispose(in: bag)

        viewModel.error.observeNext { [weak self] value in
            guard let self = self, let value = value else { return }
            self.showAlert(error: value)
        }.dispose(in: bag)
    }

    private func setupPlantData() {
        let plant = viewModel.plant.value
        title = plant.name
        descriptionLabel.text = plant.descr
        descriptionStackView.isHidden = (plant.descr ?? "").isEmpty
        setupWateringLabel()
        setupFertilizingLabel()
        imageView.image = plant.getImage()
        wateringPercentageLabel.text = "\(plant.getWateringPercentage())%"
        fertilizingPercentageLabel.text = "\(plant.getFertilizingPercentage())%"
    }

    private func setupWateringLabel() {
        let remainingWateringDays = viewModel.plant.value.getWateringRemainingDays()
        if remainingWateringDays == 0 {
            wateringLabel.text = "Watering: Today"
        } else if remainingWateringDays == 1 {
            wateringLabel.text = "Watering: Tomorrow"
        } else {
            wateringLabel.text = "Watering: In \(remainingWateringDays) days"
        }
    }

    private func setupFertilizingLabel() {
        let remainingFertilizingDays = viewModel.plant.value.getFertilizingRemainingDays()
        if remainingFertilizingDays == 0 {
            fertilizingLabel.text = "Fertilizing: Today"
        } else if remainingFertilizingDays == 1 {
            fertilizingLabel.text = "Fertilizing: Tomorrow"
        } else {
            fertilizingLabel.text = "Fertilizing: In \(remainingFertilizingDays) days"
        }
    }

    private func setupUI() {
        actionBarRoundedContainerView.layer.cornerRadius = 10
        actionBarRoundedContainerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        setupActionBarShadowContainerView()
        setupImageTopGradientView()
        setupImageRounderCornersContainerView()
        setupImageShadowContainerView()
        setupPhotoGalleryButton()
    }

    private func setupPhotoGalleryButton() {
        photoGalleryButton.layer.cornerRadius = 10
        photoGalleryButton.layer.borderColor = UIColor.green90D599.cgColor
        photoGalleryButton.layer.borderWidth = 2
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: .bold)]
        setupEditButton()
    }

    private func setupActionBarShadowContainerView() {
        actionBarShadowContainerView.layer.shadowRadius = 5
        actionBarShadowContainerView.layer.shadowColor = UIColor.black.cgColor
        actionBarShadowContainerView.layer.shadowOpacity = 0.4
        actionBarShadowContainerView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
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

    private func setupEditButton() {
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonPressed))
        editButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white,
                                           NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)], for: .normal)
        navigationItem.rightBarButtonItem = editButton
    }

    @objc
    private func editButtonPressed() {
        performSegue(withIdentifier: .pushEditPlant)
    }

}

// MARK: - UIScrollViewDelegate
extension PlantDetailsViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }

}

// MARK: - SegueHandler
extension PlantDetailsViewController: SegueHandler {

    enum SegueIdentifier: String {
        case pushEditPlant
        case pushPhotoGallery
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .pushEditPlant:
            guard let nextVC = segue.destination as? AddPlantViewController else { return }
            nextVC.viewModel = AddPlantViewModel(plant: viewModel.plant.value)

        case .pushPhotoGallery:
            guard let nextVC = segue.destination as? PhotoGalleryViewController else { return }
            nextVC.viewModel = PhotoGalleryViewModel(plantName: viewModel.plant.value.name, photos: Array(viewModel.plant.value.photos))
            nextVC.delegate = self
        }
    }

}

// MARK: - PhotoGalleryViewControllerDelegate
extension PlantDetailsViewController: PhotoGalleryViewControllerDelegate {

    func photoGalleryViewControllerDidSavePhotos(_ photos: [PlantPhoto]) {
        viewModel.setPhotos(photos)
    }

}
