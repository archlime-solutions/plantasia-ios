//
//  PlantDetailsViewController.swift
//  Plantasia
//
//  Created by bogdan razvan on 27/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit

class PlantDetailsViewController: BaseViewController {

    @IBOutlet weak var actionBarShadowContainerView: UIView!
    @IBOutlet weak var actionBarRoundedContainerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageTopGradientView: UIView!
    @IBOutlet weak var imageShadowContainerView: UIView!
    @IBOutlet weak var imageRoundedCornersContainerView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var wateringLabel: UILabel!
    @IBOutlet weak var fertilizingLabel: UILabel!
    @IBOutlet weak var wateringPercentageLabel: UILabel!
    @IBOutlet weak var fertilizingPercentageLabel: UILabel!
    @IBOutlet weak var photoGalleryButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    var viewModel: PlantDetailsViewModel!
    private var gradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPlantData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = imageTopGradientView.bounds
    }

    @IBAction func waterButtonPressed(_ sender: Any) {
        //TODO: implement
    }

    @IBAction func fertilizeButtonPressed(_ sender: Any) {
        //TODO: implement
    }

    @IBAction func photoGalleryButtonPressed(_ sender: Any) {
        //TODO: implement
    }

    @IBAction func deleteButtonPressed(_ sender: Any) {
        //TODO: implement
    }

    private func setupPlantData() {
        let plant = viewModel.plant
        title = plant.name
        descriptionLabel.text = plant.descr
        descriptionLabel.isHidden = plant.descr == nil
        setupWateringLabel()
        setupFertilizingLabel()
        imageView.image = plant.getImage()
        wateringPercentageLabel.text = "\(plant.getWateringPercentage())%"
        fertilizingPercentageLabel.text = "\(plant.getFertilizingPercentage())%"
    }

    private func setupWateringLabel() {
        let remainingWateringDays = viewModel.plant.getWateringRemainingDays()
        if remainingWateringDays == 0 {
            wateringLabel.text = "Watering: Today"
        } else if remainingWateringDays == 1 {
            wateringLabel.text = "Watering: Tomorrow"
        } else {
            wateringLabel.text = "Watering: In \(remainingWateringDays) days"
        }
    }

    private func setupFertilizingLabel() {
        let remainingFertilizingDays = viewModel.plant.getFertilizingRemainingDays()
        if remainingFertilizingDays == 0 {
            fertilizingLabel.text = "Fertilizing: Today"
        } else if remainingFertilizingDays == 1 {
            fertilizingLabel.text = "Fertilizing: Tomorrow"
        } else {
            fertilizingLabel.text = "Fertilizing: In \(remainingFertilizingDays) days"
        }
    }

    private func setupUI() {
        setupNavigationBar()
        actionBarRoundedContainerView.layer.cornerRadius = 10
        actionBarRoundedContainerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        setupActionBarShadowContainerView()
        setupImageTopGradientView()
        setupImageRounderCornersContainerView()
        setupImageShadowContainerView()
        setupPhotoGalleryButton()
        setupDeleteButton()
    }

    private func setupPhotoGalleryButton() {
        photoGalleryButton.layer.cornerRadius = 10
        photoGalleryButton.layer.borderColor = UIColor.green90D599.cgColor
        photoGalleryButton.layer.borderWidth = 2
    }

    private func setupDeleteButton() {
        deleteButton.layer.cornerRadius = 10
        deleteButton.layer.borderColor = UIColor.orangeFE865D.cgColor
        deleteButton.layer.borderWidth = 2
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
        //TODO: implement
    }

}
