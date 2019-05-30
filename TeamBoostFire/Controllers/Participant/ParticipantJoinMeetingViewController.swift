//
//  ParticipantJoinMeetingViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class ParticipantJoinMeetingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var participantNameTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var number1TextField: UITextField!
    @IBOutlet weak var number2TextField: UITextField!
    @IBOutlet weak var number3TextField: UITextField!
    @IBOutlet weak var number4TextField: UITextField!
    @IBOutlet weak var number5TextField: UITextField!
    @IBOutlet weak var number6TextField: UITextField!

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

        number1TextField.delegate = self
        number2TextField.delegate = self
        number3TextField.delegate = self
        number4TextField.delegate = self
        number5TextField.delegate = self
        number6TextField.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTestEnvironmentIfNeeded()
    }

    private func setupTestEnvironmentIfNeeded() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.testEnvironment == true {
            populateMeetingCodeUITextField(with: StubMeetingVars.MeetingCode.rawValue)
            participantNameTextField.text = UUID().uuidString
        }
    }


    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let currentText = textField.text
        let newString = string

        let isDeleted = newString.count == 0 && currentText?.count != 0
        let isNewCharacterEntered = newString.count == 1 && currentText?.count == 0
        if isDeleted {
            textField.text = string
            return true
        } else if isNewCharacterEntered {
            let nextTextTag = textField.tag + 1
            let nextResponder = textField.superview?.viewWithTag(nextTextTag)
            if nextResponder == nil {
                textField.resignFirstResponder()
            }

            if (nextResponder != nil){
                nextResponder?.becomeFirstResponder()
            }
            textField.text = string
            return true
        } else {
            return false
        }
    }

    @IBAction func joinMeetingButtonClicked(_ sender: Any) {
        let meetingCodeText = meetingCodeFromTextFields()
        if meetingCodeText.count == 0 {
            let alertController = UIAlertController(title: "Incomplete data",
                                                    message: "Please enter IP Address of the Host",
                                                    preferredStyle: .alert)

            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }

        guard let participantNameText = participantNameTextField.text else {
            return
        }

        if participantNameText.count == 0 {
            let alertController = UIAlertController(title: "Incomplete data",
                                                    message: "Please enter your name to join the meeting",
                                                    preferredStyle: .alert)

            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }

        let participantIdentifier = UUID().uuidString
        let participant = Participant(id: participantIdentifier,
                                      name: participantNameText, speakerOrder: -1)
        ParticipantCoreServices.shared.setupCore(with: participant, meetingCode: meetingCodeText)
        present(ParticipantLobbyViewController(), animated: true, completion: nil)

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

    // MARK: - Meeting code helpers
    private func populateMeetingCodeUITextField(with string: String) {
        if string.count != 6 {
            assertionFailure("Invalid number of characters in the meeting code string")
            return
        }

        let splitableString = SplitableString(from: string)
        number1TextField.text = splitableString.code1
        number2TextField.text = splitableString.code2
        number3TextField.text = splitableString.code3
        number4TextField.text = splitableString.code4
        number5TextField.text = splitableString.code5
        number6TextField.text = splitableString.code6
    }

    private func meetingCodeFromTextFields() -> String {
        var meetingCode = number1TextField.text ?? ""
        meetingCode = meetingCode + (number2TextField.text ?? "")
        meetingCode = meetingCode + (number3TextField.text ?? "")
        meetingCode = meetingCode + "-"
        meetingCode = meetingCode + (number4TextField.text ?? "")
        meetingCode = meetingCode + (number5TextField.text ?? "")
        meetingCode = meetingCode + (number6TextField.text ?? "")
        return meetingCode
    }
}

fileprivate struct SplitableString {
    let code1: String
    let code2: String
    let code3: String
    let code4: String
    let code5: String
    let code6: String

    init(from string: String) {
        let arrayString = Array(string)
        self.code1 = String(arrayString[0])
        self.code2 = String(arrayString[1])
        self.code3 = String(arrayString[2])
        self.code4 = String(arrayString[3])
        self.code5 = String(arrayString[4])
        self.code6 = String(arrayString[5])
    }
}
