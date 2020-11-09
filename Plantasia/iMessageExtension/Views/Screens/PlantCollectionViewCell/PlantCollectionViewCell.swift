//
//  PlantCollectionViewCell.swift
//  Plantasia
//
//  Created by bogdan razvan on 06/11/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit

class PlantCollectionViewCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!

    // MARK: - Properties
    var viewModel: PlantCollectionViewCellViewModel! {
        didSet {
            configurePlantDetails()
        }
    }

    // MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    // MARK: - Properties
    private func setupUI() {
        imageView.layer.cornerRadius = 8
    }

    private func configurePlantDetails() {
        let image = viewModel.plant.getImage()
        imageView.image = image
    }

}
