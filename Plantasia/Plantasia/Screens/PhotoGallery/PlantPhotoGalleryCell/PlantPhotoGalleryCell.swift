//
//  PlantPhotoGalleryCell.swift
//  Plantasia
//
//  Created by bogdan razvan on 30/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit

protocol PlantPhotoGalleryCellDelegate: class {
    func plantPhotoGalleryCellDidPressDelete(index: Int)
}

class PlantPhotoGalleryCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var shadowContainerView: UIView!
    @IBOutlet weak var roundedContainerView: UIView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!

    // MARK: - Properties
    var viewModel: PlantPhotoGalleryCellViewModel! {
        didSet {
            configurePlantDetails()
        }
    }
    weak var delegate: PlantPhotoGalleryCellDelegate?

    // MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    // MARK: - IBActions
    @IBAction func deleteButtonPressed(_ sender: Any) {
        delegate?.plantPhotoGalleryCellDidPressDelete(index: viewModel.index)
    }

    // MARK: - Private
    private func configurePlantDetails() {
        plantImageView.image = viewModel.plantPhoto.getImage()
        creationDateLabel.text = viewModel.plantPhoto.creationDate?.toShortMonthDateString()
        if viewModel.isInEditingMode {
            startWiggling()
            deleteButton.isHidden = false
        } else {
            deleteButton.isHidden = true
        }
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
