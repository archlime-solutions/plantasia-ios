//
//  GardenViewController.swift
//  Plantasia
//
//  Created by bogdan razvan on 25/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit
import RealmSwift

class GardenViewController: BaseViewController, AlertPresenter {

    @IBOutlet weak var emptyGardenContainerView: UIView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var filledGardenContainerView: UIView!
    @IBOutlet weak var quickActionsContainerView: UIView!
    @IBOutlet weak var waterAllView: UIView!
    @IBOutlet weak var fertilizeAllView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!

    private let viewModel = GardenViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        viewModel.loadPlants()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupContainerViewsVisibility()
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

    func loadPlants() {
        viewModel.loadPlants()
    }

    private func setupBindings() {
        viewModel.event.observeNext { [weak self] event in
            guard let self = self else { return }
            if let event = event {
                switch event {
                case .didLoadPlants:
                    self.setupContainerViewsVisibility()
                case .didWaterAllPlants, .didFertilizeAllPlants:
                    self.collectionView.reloadData()
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
        let handler: () -> Void = {
            self.viewModel.waterAllPlants()
        }
        showAlert(title: "Are you sure you want mark all plants as watered?",
                  message: nil,
                  buttonText: "Yes",
                  buttonHandler: handler,
                  showCancelButton: true)
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
        let handler: () -> Void = {
            self.viewModel.fertilizeAllPlants()
        }
        showAlert(title: "Are you sure you want to mark all plants as fertilized? ",
                  message: nil,
                  buttonText: "Yes",
                  buttonHandler: handler,
                  showCancelButton: true)
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

    private func setupAddPlantBarButtonItem() {
        let addPlantView: AddPlantBarButtonItemView = AddPlantBarButtonItemView.fromNib()
        addPlantView.delegate = self
        let button = UIBarButtonItem(customView: addPlantView)
        navigationItem.rightBarButtonItem = button
    }

    private func setupSortPlantsBarButtonItem() {
        let sortPlantsView: SortPlantsBarButtonItemView = SortPlantsBarButtonItemView.fromNib()
        sortPlantsView.delegate = self
        let button = UIBarButtonItem(customView: sortPlantsView)
        navigationItem.leftBarButtonItem = button
    }

    private func setupContainerViewsVisibility() {
        if viewModel.plants.isEmpty {
            filledGardenContainerView.isHidden = true
            emptyGardenContainerView.isHidden = false
            quickActionsContainerView.isHidden = true
            plusButton.layer.cornerRadius = plusButton.bounds.height / 2
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
        } else {
            filledGardenContainerView.isHidden = false
            emptyGardenContainerView.isHidden = true
            quickActionsContainerView.isHidden = false
            setupQuickActionsContainerView()
            setupWaterAllView()
            setupFertilizeAllView()
            setupAddPlantBarButtonItem()
            setupSortPlantsBarButtonItem()
            collectionView.dragInteractionEnabled = true
            collectionView.reloadData()
        }
    }

    private func setupQuickActionsContainerView() {
        quickActionsContainerView.layer.shadowRadius = 1
        quickActionsContainerView.layer.shadowColor = UIColor.black.cgColor
        quickActionsContainerView.layer.shadowOpacity = 0.1
        quickActionsContainerView.layer.shadowOffset = CGSize(width: 0, height: 3.0)
    }

}

// MARK: - SegueHandler
extension GardenViewController: SegueHandler {

    enum SegueIdentifier: String {
        case presentAddPlant
        case pushPlantDetails
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .presentAddPlant:
            guard let nextVC = (segue.destination as? UINavigationController)?.viewControllers.first as? AddPlantViewController else { return }
            nextVC.viewModel = AddPlantViewModel(plant: nil)
            nextVC.delegate = self
        case .pushPlantDetails:
            guard let selectedPlant = viewModel.selectedPlant, let nextVC = segue.destination as? PlantDetailsViewController else { return }
            nextVC.viewModel = PlantDetailsViewModel(plant: selectedPlant)
        }
    }

}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate
extension GardenViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
    UICollectionViewDragDelegate, UICollectionViewDropDelegate {

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return viewModel.plants.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell =
                collectionView.dequeueReusableCell(withReuseIdentifier: "PlantDetailsCollectionViewCell", for: indexPath) as? PlantDetailsCollectionViewCell else {
                    return UICollectionViewCell()
            }
            cell.viewModel = PlantDetailsCollectionViewCellViewModel(plant: viewModel.plants[indexPath.row])
            return cell
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 156, height: 200)
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                            minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 20
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 20
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        }

        func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
            let item = viewModel.plants[indexPath.row]
            let itemProvider = NSItemProvider(object: item)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = item
            return [dragItem]
        }

        func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
            guard let destinationIndexPath = coordinator.destinationIndexPath,
                destinationIndexPath.row >= 0, coordinator.items.count == 1,
                let item = coordinator.items.first,
                let sourceIndexPath = item.sourceIndexPath,
                let draggedPlant = item.dragItem.localObject as? Plant
                else { return }

            collectionView.performBatchUpdates({
                self.viewModel.movePlant(draggedPlant, fromPosition: sourceIndexPath.row, toPosition: destinationIndexPath.row)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            })
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }

        func collectionView(_ collectionView: UICollectionView,
                            dropSessionDidUpdate session: UIDropSession,
                            withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
            guard let destinationIndexPath = destinationIndexPath else {
                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }

            if session.localDragSession != nil, destinationIndexPath.row >= 0 {
                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            } else {
                return UICollectionViewDropProposal(operation: .forbidden)
            }
        }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            viewModel.selectedPlant = viewModel.plants[indexPath.row]
            performSegue(withIdentifier: .pushPlantDetails)
        }

}

// MARK: - AddPlantBarButtonItemViewDelegate
extension GardenViewController: AddPlantBarButtonItemViewDelegate {

    func addPlantBarButtonItemViewPressed() {
        performSegue(withIdentifier: .presentAddPlant)
    }

}

// MARK: - SortPlantsBarButtonItemViewDelegate
extension GardenViewController: SortPlantsBarButtonItemViewDelegate {

    func sortPlantsBarButtonItemViewPressed() {
        let alert = UIAlertController(title: "Select a sorting criteria", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Hydration", style: .default, handler: { _ in
            self.viewModel.sortingCriteria = .hydration
        }))

        alert.addAction(UIAlertAction(title: "Fertilization", style: .default, handler: { _ in
            self.viewModel.sortingCriteria = .fertilization
        }))

        alert.addAction(UIAlertAction(title: "Date Added", style: .default, handler: { _ in
            self.viewModel.sortingCriteria = .dateAdded
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            print("User click Dismiss button")
        }))

        present(alert, animated: true, completion: nil)
    }

}

// MARK: - AddPlantViewControllerDelegate
extension GardenViewController: AddPlantViewControllerDelegate {

    func addPlantViewControllerDidCreatePlant() {
        viewModel.loadPlants()
    }

}
