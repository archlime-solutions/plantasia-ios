//
//  GardenViewController.swift
//  Plantasia
//
//  Created by bogdan razvan on 25/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit
import RealmSwift

class GardenViewController: BaseViewController {

    @IBOutlet weak var emptyGardenContainerView: UIView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var filledGardenContainerView: UIView!
    @IBOutlet weak var quickActionsContainerView: UIView!
    @IBOutlet weak var waterAllView: UIView!
    @IBOutlet weak var fertilizeAllView: UIView!

    private let viewModel = GardenViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getPlants()
        setupInitialViewsVisibility()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupPlusButtonAnimation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        plusButton.layer.removeAllAnimations()
    }

    @IBAction func plusButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: .presentAddPlant)
    }

    private func setupUI() {
        plusButton.layer.cornerRadius = plusButton.bounds.height / 2
        setupWaterAllView()
        setupFertilizeAllView()
    }

    private func setupBindings() {
        viewModel.event.observeNext { [weak self] event in
            guard let self = self else { return }
            if let event = event {
                switch event {
                case .didGetPlants: self.setupInitialViewsVisibility()
                }
            }
        }.dispose(in: bag)
    }

    private func setupWaterAllView() {
        waterAllView.layer.cornerRadius = 10
        waterAllView.layer.borderWidth = 2
        waterAllView.layer.borderColor = UIColor.blue69A8AD.cgColor
        waterAllView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(waterAllViewPressed)))
    }

    @objc
    private func waterAllViewPressed() {
        waterAllView.flash()
        //TODO: implement
    }

    private func setupFertilizeAllView() {
        fertilizeAllView.layer.cornerRadius = 10
        fertilizeAllView.layer.borderWidth = 2
        fertilizeAllView.layer.borderColor = UIColor.orangeFE865D.cgColor
        fertilizeAllView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fertilizeAllViewPressed)))
    }

    @objc
    private func fertilizeAllViewPressed() {
        fertilizeAllView.flash()
        //TODO: implement
    }

    private func setupPlusButtonAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = NSNumber(value: 0.9)
        animation.duration = 1
        animation.repeatCount = 100
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        plusButton.layer.add(animation, forKey: nil)
    }

    private func setupInitialViewsVisibility() {
        if viewModel.plants.isEmpty {
            filledGardenContainerView.isHidden = true
            emptyGardenContainerView.isHidden = false
            quickActionsContainerView.isHidden = true
        } else {
            filledGardenContainerView.isHidden = false
            emptyGardenContainerView.isHidden = true
            quickActionsContainerView.isHidden = false
        }
    }

}

extension GardenViewController: SegueHandler {

    enum SegueIdentifier: String {
        case presentAddPlant
    }

}
