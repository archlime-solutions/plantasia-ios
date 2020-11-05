//
//  AddPlantBarButtonItemView.swift
//  Plantasia
//
//  Created by bogdan razvan on 26/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit

protocol AddPlantBarButtonItemViewDelegate: class {
    func addPlantBarButtonItemViewPressed()
}

class AddPlantBarButtonItemView: UIView {

    // MARK: - Properties
    weak var delegate: AddPlantBarButtonItemViewDelegate?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addPlantBarButtonItemViewPressed)))
    }

    // MARK: - Private
    @objc
    private func addPlantBarButtonItemViewPressed() {
        flash()
        delegate?.addPlantBarButtonItemViewPressed()
    }
}
