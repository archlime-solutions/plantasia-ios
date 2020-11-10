//
//  PlantsViewController.swift
//  iMessageExtension
//
//  Created by bogdan razvan on 06/11/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit
import Messages

class PlantsViewController: MSMessagesAppViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var plantsCollectionView: UICollectionView!
    @IBOutlet weak var emptyContainerView: UIStackView!

    // MARK: - Properties
    private let viewModel = PlantsViewModel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        viewModel.loadPlants()
    }

    // MARK: - IBActions
    @IBAction func emptyContainerViewPressed(_ sender: Any) {
        guard let url: URL = URL(string: "Plantasia") else { return }
        extensionContext?.open(url, completionHandler: { _ in })
    }

    // MARK: - Private
    private func setupBindings() {
        viewModel.event.observeNext { [weak self] event in
            guard let self = self else { return }
            if let event = event {
                switch event {
                case .didLoadPlants(let success):
                    if success {
                        if !self.viewModel.plants.isEmpty {
                            self.emptyContainerView.isHidden = true
                            self.plantsCollectionView.isHidden = false
                            self.plantsCollectionView.reloadData()
                        }
                    } else {
                        //TODO: log error
                    }
                }
            }
        }.dispose(in: bag)
    }

    private func createMessage(with plant: Plant) -> MSMessage {
        let layout = MSMessageTemplateLayout()
        layout.image = plant.getImage()
        layout.imageTitle = plant.name
        let message = MSMessage()
        message.layout = layout
        return message
    }

}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension PlantsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.plants.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: "PlantCollectionViewCell", for: indexPath) as? PlantCollectionViewCell else {
                return UICollectionViewCell()
        }
        cell.viewModel = PlantCollectionViewCellViewModel(plant: viewModel.plants[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let conversation = activeConversation else { return }
        conversation.insert(createMessage(with: viewModel.plants[indexPath.row])) { error in
            if error != nil {
                //TODO: log error
            }
        }

    }

}
