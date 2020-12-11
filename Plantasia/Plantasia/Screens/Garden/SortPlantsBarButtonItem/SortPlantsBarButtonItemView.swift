//
//  SortPlantsBarButtonItemView.swift
//  Plantasia
//
//  Created by bogdan razvan on 26/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit

protocol SortPlantsBarButtonItemViewDelegate: class {
    func sortPlantsBarButtonItemViewPressed()
}

class SortPlantsBarButtonItemView: UIView {

    // MARK: - Properties
    weak var delegate: SortPlantsBarButtonItemViewDelegate?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sortPlantsBarButtonItemViewPressed)))
    }

    // MARK: - Private
    @objc
    private func sortPlantsBarButtonItemViewPressed() {
        flash()
        delegate?.sortPlantsBarButtonItemViewPressed()
    }
}
