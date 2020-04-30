//
//  PhotoGalleryViewController.swift
//  Plantasia
//
//  Created by bogdan razvan on 30/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit

protocol PhotoGalleryViewControllerDelegate: class {
    func photoGalleryViewControllerDidSavePhotos(_: [PlantPhoto])
}

class PhotoGalleryViewController: BaseViewController, AlertPresenter {

    @IBOutlet weak var emptyGalleryContainerView: UIView!
    @IBOutlet weak var filledGalleryContainerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var plusButton: UIButton!

    var viewModel: PhotoGalleryViewModel!
    //TODO: calld elegate when press back
    weak var delegate: PhotoGalleryViewControllerDelegate?
    private var mediaPicker = MediaPicker()
    private var isInEditingMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupContainerViewsVisibility()
        plusButton.layer.cornerRadius = plusButton.bounds.height / 2
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupPlusButtonAnimation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            delegate?.photoGalleryViewControllerDidSavePhotos(viewModel.photos)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        plusButton.layer.removeAllAnimations()
    }

    @IBAction func plusButtonPressed(_ sender: Any) {
        mediaPicker.pickImage(self, { image in
            self.viewModel.photos.append(PlantPhoto(image: image))
            self.setupContainerViewsVisibility()
        })
    }

    private func setupNavigationBar() {
        title = viewModel.plantName
        navigationController?.navigationBar.tintColor = .black232323
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black232323]
    }

    private func setupContainerViewsVisibility() {
        if viewModel.photos.isEmpty {
            filledGalleryContainerView.isHidden = true
            emptyGalleryContainerView.isHidden = false
        } else {
            filledGalleryContainerView.isHidden = false
            emptyGalleryContainerView.isHidden = true
            setupRightBarButtonItem()
            collectionView.dragInteractionEnabled = true
            collectionView.reloadData()
        }
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

    private func setupRightBarButtonItem() {
        if isInEditingMode {
            let editButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonPressed))
            editButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black232323,
                                               NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)], for: .normal)
            navigationItem.rightBarButtonItem = editButton
        } else {
            let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonPressed))
            editButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black232323,
                                               NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)], for: .normal)
            navigationItem.rightBarButtonItem = editButton
        }
    }

    @objc
    private func editButtonPressed(_ sender: Any) {
        isInEditingMode = true
        collectionView.reloadData()
        setupRightBarButtonItem()
    }

    @objc
    private func doneButtonPressed(_ sender: Any) {
        isInEditingMode = false
        collectionView.reloadData()
        setupRightBarButtonItem()
    }

}

extension PhotoGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: "PlantPhotoGalleryCell", for: indexPath) as? PlantPhotoGalleryCell else {
                return UICollectionViewCell()
        }
        cell.viewModel = PlantPhotoGalleryCellViewModel(plantPhoto: viewModel.photos[indexPath.row], index: indexPath.row, isInEditingMode: isInEditingMode)
        cell.delegate = self
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

    //TODO: implement didSelect cu ceva screen cu poza full screen, numele si data plm... vezi tu un design rapid
    //TODO: implement drag and drop? nu am index, vad eu cum fac

}

// MARK: - PlantPhotoGalleryCellDelegate
extension PhotoGalleryViewController: PlantPhotoGalleryCellDelegate {

    func plantPhotoGalleryCellDidPressDelete(index: Int) {
        let handler: () -> Void = {
            self.viewModel.photos.remove(at: index)
            let range = Range(uncheckedBounds: (0, self.collectionView.numberOfSections))
            let indexSet = IndexSet(integersIn: range)
            self.collectionView.reloadSections(indexSet)
        }
        showAlert(title: "Are you sure you want to remove this photo?",
                  message: "This will permanently remove this photo from the gallery.",
                  buttonText: "Remove",
                  buttonHandler: handler,
                  buttonStyle: .destructive,
                  showCancelButton: true)
    }

}
