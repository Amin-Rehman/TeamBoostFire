//
//  HostSetupMeetingViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit
import TeamBoostKit

enum ModerationStateLabel: String {
    case AutoModerated = "Auto Moderated"
    case Uniform = "Unmoderated"
}

enum ModerationDescriptionText: String {
    case AutoModerated = "The app recommends who speaks and for how long based on their total participation in the meeting"
    case Uniform = "Everyone is given the same amount of time to speak and in the same order"
}

class HostSetupMeetingViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var agendaQuestionTextField: UITextField!
    @IBOutlet weak var meetingTimeTextField: UITextField!
    @IBOutlet weak var maxTalkingTimeTextField: UITextField!
    @IBOutlet weak var moderationSwitch: UISwitch!
    @IBOutlet weak var moderationStateLabel: UILabel!
    @IBOutlet weak var moderationDescriptionLabel: UILabel!


    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let center = NotificationCenter.default
        center.addObserver(self, selector:
            #selector(handleKeyboardAction),
                           name: UIResponder.keyboardWillShowNotification,
                           object: nil)

        center.addObserver(self, selector:
            #selector(handleKeyboardAction),
                           name: UIResponder.keyboardWillHideNotification,
                           object: nil)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        refreshModerationState()
    }

    private func refreshModerationState() {
        if moderationSwitch.isOn {
            moderationStateLabel.text = ModerationStateLabel.AutoModerated.rawValue
            moderationDescriptionLabel.text = ModerationDescriptionText.AutoModerated.rawValue
        } else {
            moderationStateLabel.text = ModerationStateLabel.Uniform.rawValue
            moderationDescriptionLabel.text = ModerationDescriptionText.Uniform.rawValue
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTestEnvironmentIfNeeded()
    }
    private func setupTestEnvironmentIfNeeded() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.testEnvironment == true {
            agendaQuestionTextField.text = StubMeetingVars.MeetingAgenda.rawValue
            meetingTimeTextField.text = StubMeetingVars.MeetingTime.rawValue
            maxTalkingTimeTextField.text = StubMeetingVars.MaxTalkTime.rawValue

        }
    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        guard let agendaQuestion = agendaQuestionTextField?.text else {
            return
        }
        guard let meetingTime = meetingTimeTextField?.text else {
            return
        }
        guard let maxTalkingTime = maxTalkingTimeTextField?.text else {
            return
        }

        if agendaQuestion.count == 0 || meetingTime.count == 0 || maxTalkingTime.count == 0 {
            let alertController = UIAlertController(title: "Incomplete data",
                                                    message: "Please enter all required fields",
                                                    preferredStyle: .alert)

            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }

        var moderationMode: MeetingMode

        if moderationSwitch.isOn  {
            moderationMode = .AutoModerated
        } else {
            moderationMode = .Uniform
        }

        let meetingParams = MeetingsParams(agenda: agendaQuestion,
                                           meetingTime: Int(meetingTime)!,
                                           maxTalkTime: Int(maxTalkingTime)!,
                                           moderationMode: moderationMode)
        HostSetupMeetingUseCase.perform(at: self, meetingParams: meetingParams)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func handleKeyboardAction(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
    }

    @IBAction func switchToggled(_ sender: Any) {
        refreshModerationState()
    }
}
