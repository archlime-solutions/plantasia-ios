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

class SettingsViewController: BaseViewController, AlertPresenter {

    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var reminderTextField: UITextField!
    @IBOutlet weak var writeAReviewButton: UIButton!
    @IBOutlet weak var contactUsButton: UIButton!
    @IBOutlet weak var shareAppButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!

    // MARK: - Properties
    private var timePicker = UIDatePicker()
    private var viewModel = SettingsViewModel()
    private var appID = "1510768461"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    // MARK: - IBActions
    @IBAction func writeAReviewButtonPressed(_ sender: Any) {
        let urlStr = "https://itunes.apple.com/app/id\(appID)?action=write-review"
        guard let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @IBAction func contactButtonPressed(_ sender: Any) {
        let address = "contact@archlime.com"
        let subject = "Plantasia - User Feedback"

        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients([address])
            mailComposerVC.setSubject(subject)
            present(mailComposerVC, animated: true, completion: nil)
        } else {
            let googleUrlString =
                """
                googlegmail:///co?to=\(address.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ??
                "")&subject=\(subject.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")
                """
            if let googleUrl = URL(string: googleUrlString) {
                UIApplication.shared.open(googleUrl, options: [:]) { success in
                    if !success {
                        self.showAlert(title: "You need to have either Mail or Gmail installed in order to send emails.")
                    }
                }
            }
        }
    }

    @IBAction func shareAppButtonPressed(_ sender: Any) {
        if let myWebsite = URL(string: "http://itunes.apple.com/app/id\(appID)") {
            let textToShare = "Check out Plantasia, your mobile garden companion 🌿. Download link 👉"
            let objectsToShare = [textToShare, myWebsite, #imageLiteral(resourceName: "logo")] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = view
            present(activityVC, animated: true, completion: nil)
        }
    }

    // MARK: - Private
    private func setupUI() {
        setReminderTextFieldText()
        setupTimePicker()
        setupButtons()
        setupVersionLabel()
    }

    private func setupVersionLabel() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
            versionLabel.text = "Version \(version)"
        } else {
            versionLabel.isHidden = true
        }
    }

    private func setupButtons() {
        [writeAReviewButton, contactUsButton, shareAppButton].forEach {
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
                self.reminderTextField.animateScale()
            }
        }.dispose(in: bag)
    }

    private func setReminderTextFieldText() {
        let attrs1 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.black232323]
        let attrs2 = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.green90D599]
        let attributedString1 = NSMutableAttributedString(string: "I want to be reminded at ", attributes: attrs1)
        let attributedString2 = NSMutableAttributedString(string: UserDefaults.standard.getRemindersTime().toHoursMinutesString(), attributes: attrs2)
        attributedString1.append(attributedString2)
        reminderTextField.attributedText = attributedString1
    }

    private func setupTimePicker() {
        timePicker.addTarget(self, action: #selector(timePickerValueChanged), for: .valueChanged)
        timePicker.datePickerMode = .time
        timePicker.setDate(UserDefaults.standard.getRemindersTime(), animated: true)
        timePicker.backgroundColor = .whiteFFFFFF
        if #available(iOS 13.4, *) {
            timePicker.preferredDatePickerStyle = .wheels
        }
        let timePickerToolbar = UIToolbar()
        timePickerToolbar.barTintColor = .whiteFFFFFF
        timePickerToolbar.tintColor = .black232323
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
