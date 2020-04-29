//
//  SettingsViewController.swift
//  Plantasia
//
//  Created by bogdan razvan on 28/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI

class SettingsViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var reminderTextField: UITextField!
    @IBOutlet weak var replayTutorialButton: UIButton!
    @IBOutlet weak var writeAReviewButton: UIButton!
    @IBOutlet weak var contactUsButton: UIButton!
    @IBOutlet weak var shareAppButton: UIButton!
    @IBOutlet weak var navigationBarShadowView: UIView!

    private var timePicker = UIDatePicker()
    private var viewModel = SettingsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    @IBAction func replayTutorialButtonPressed(_ sender: Any) {
        //TODO: implement
    }

    @IBAction func writeAReviewButtonPressed(_ sender: Any) {
        SKStoreReviewController.requestReview()
    }

    @IBAction func contactButtonPressed(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients(["contact@archlime.com"])
            //TODO: change this text
            mailComposerVC.setSubject("CHANGE THIS")
            present(mailComposerVC, animated: true, completion: nil)
        }
    }

    @IBAction func shareAppButtonPressed(_ sender: Any) {
        //TODO: change text
        let textToShare = "Check out my app"

        //TODO: change link
        if let myWebsite = URL(string: "http://itunes.apple.com/app/idXXXXXXXXX") {
            //TODO: change image from placeholder to logo
            let objectsToShare = [textToShare, myWebsite, #imageLiteral(resourceName: "placeholder")] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = view
            present(activityVC, animated: true, completion: nil)
        }
    }

    private func setupUI() {
        setReminderTextFieldText()
        setupTimePicker()
        setupButtons()
        setupNavigationBarShadow()
    }

    private func setupNavigationBarShadow() {
        navigationController?.navigationBar.layer.masksToBounds = false
        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.1
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        navigationController?.navigationBar.layer.shadowRadius = 1
    }

    private func setupButtons() {
        [replayTutorialButton, writeAReviewButton, contactUsButton, shareAppButton].forEach {
            $0?.layer.cornerRadius = 10
            $0?.layer.borderWidth = 2
            $0?.layer.borderColor = UIColor.green90D599.cgColor
        }
    }

    private func setupBindings() {
        viewModel.event.observeNext { [weak self] value in
            guard let self = self, let value = value else { return }
            switch value {
            case .didSetReminderTime:
                self.setReminderTextFieldText()
            }
        }.dispose(in: bag)
    }

    private func setReminderTextFieldText() {
        let attrs1 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.black232323]
        let attrs2 = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.green90D599]
        let attributedString1 = NSMutableAttributedString(string: "Send a reminder at ", attributes: attrs1)
        let attributedString2 = NSMutableAttributedString(string: UserDefaults.standard.getRemindersTime().toHoursMinutesString(), attributes: attrs2)
        attributedString1.append(attributedString2)
        reminderTextField.attributedText = attributedString1
    }

    private func setupTimePicker() {
        timePicker.addTarget(self, action: #selector(timePickerValueChanged), for: .valueChanged)
        timePicker.datePickerMode = .time
        timePicker.setDate(UserDefaults.standard.getRemindersTime(), animated: true)
        timePicker.backgroundColor = .white
        let timePickerToolbar = UIToolbar()
        timePickerToolbar.barTintColor = .white
        timePickerToolbar.tintColor = .green90D599
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        timePickerToolbar.setItems([flexButton, doneButton], animated: true)
        timePickerToolbar.sizeToFit()
        reminderTextField.inputView = timePicker
        reminderTextField.inputAccessoryView = timePickerToolbar
    }

    @objc
    private func timePickerValueChanged(_ datePicker: UIDatePicker) {
        viewModel.setReminderTime(datePicker.date)
    }

    @objc
    private func doneButtonPressed() {
        view.endEditing(true)
    }

}

// MARK: - UITextFieldDelegate
extension SettingsViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }

}

// MARK: - MFMailComposeViewControllerDelegate
extension SettingsViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}
