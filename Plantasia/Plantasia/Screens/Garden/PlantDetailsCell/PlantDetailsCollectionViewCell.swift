//
//  PlantDetailsCollectionViewCell.swift
//  Plantasia
//
//  Created by bogdan razvan on 26/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit

class PlantDetailsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var shadowContainerView: UIView!
    @IBOutlet weak var roundedContainerView: UIView!
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var wateringLabel: UILabel!
    @IBOutlet weak var fertilizingLabel: UILabel!

    var viewModel: PlantDetailsCollectionViewCellViewModel! {
        didSet {
            configurePlantDetails()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func configurePlantDetails() {
        let plant = viewModel.plant
        nameLabel.text = plant.name
        wateringLabel.text = "\(plant.getWateringPercent())%"
        fertilizingLabel.text = "\(plant.getFertilizingPercent())%"
        self.plantImageView.image = plant.getThumbnailImage()
    }

    private func setupUI() {
        setupGradientView()
        setupShadowContainerView()
        roundedContainerView.layer.cornerRadius = 10
    }

    private func setupGradientView() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.9).cgColor]
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupShadowContainerView() {
        shadowContainerView.layer.shadowRadius = 5
        shadowContainerView.layer.shadowColor = UIColor.black.cgColor
        shadowContainerView.layer.shadowOpacity = 0.4
        shadowContainerView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
    }
}
