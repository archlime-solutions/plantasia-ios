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

    weak var delegate: SortPlantsBarButtonItemViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sortPlantsBarButtonItemViewPressed)))
    }

    @objc
    private func sortPlantsBarButtonItemViewPressed() {
        flash()
        delegate?.sortPlantsBarButtonItemViewPressed()
    }
}
