//
//  ParticipantJoinMeetingViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class ParticipantJoinMeetingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var meetingCode: UITextField!
    @IBOutlet weak var participantNameTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
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

        super.viewDidLoad()
    }

    override func viewDidDisappear(_ animated: Bool) {
    }

    @IBAction func joinMeetingButtonClicked(_ sender: Any) {
        let meetingCodeText = meetingCode.text
        if meetingCodeText?.count == 0 {
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
        let participant = Participant(id: participantIdentifier, name: participantNameText)
        CoreServices.shared.setupMeetingAsParticipant(participant: participant, meetingCode: meetingCodeText!)

        /*
        ParticipantJoinMeetingUseCase.perform(at: self,
                                              participantName: participantNameText,
                                              hostIPAddress: hostIPAddressText!)
         */
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

}
