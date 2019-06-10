//
//  ParticipantJoinMeetingViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit
import TransitionButton

class ParticipantJoinMeetingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var participantNameTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var transitionButtonContainer: UIView!
    var transitionButton: TransitionButton?

    @IBOutlet weak var number1TextField: UITextField!
    @IBOutlet weak var number2TextField: UITextField!
    @IBOutlet weak var number3TextField: UITextField!
    @IBOutlet weak var number4TextField: UITextField!
    @IBOutlet weak var number5TextField: UITextField!
    @IBOutlet weak var number6TextField: UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardInteraction()
        setupMeetingCodeTextFieldDelegates()

        let transitionButtonWidth = CGFloat(200.0)
        let parentViewWidth = transitionButtonContainer.frame.width
        let xOffset = (parentViewWidth - transitionButtonWidth) / 2

        transitionButton =  TransitionButton(frame: CGRect(x: xOffset, y: 0,
                                                           width: transitionButtonWidth,
                                                           height: 40))
        transitionButtonContainer.addSubview(transitionButton!)

        transitionButton!.backgroundColor = UIColor(red: 0.220000,
                                                    green: 0.330000,
                                                    blue: 0.530000,
                                                    alpha: 1.0)
        transitionButton!.setTitle("Join Meeting", for: .normal)
        transitionButton!.cornerRadius = 20
        transitionButton!.spinnerColor = .white
        transitionButton!.addTarget(self, action: #selector(transitionButtonAction(_:)), for: .touchUpInside)
    }

    @IBAction func transitionButtonAction(_ button: TransitionButton) {
        button.startAnimation() // 2: Then start the animation when the user tap the button
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            // A small sleep just to show the animation ;) 
            sleep(2)
            DispatchQueue.main.async(execute: { () -> Void in
                // 4: Stop the animation, here you have three options for the `animationStyle` property:
                // .expand: useful when the task has been compeletd successfully and you want to expand the button and transit to another view controller in the completion callback
                // .shake: when you want to reflect to the user that the task did not complete successfly
                // .normal
                button.stopAnimation(animationStyle: .expand, completion: {
                    self.joinMeeting()
                })
            })
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTestEnvironmentIfNeeded()
    }


    private func setupKeyboardInteraction() {
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

    }

    private func setupMeetingCodeTextFieldDelegates() {
        number1TextField.delegate = self
        number2TextField.delegate = self
        number3TextField.delegate = self
        number4TextField.delegate = self
        number5TextField.delegate = self
        number6TextField.delegate = self
    }

    private func setupTestEnvironmentIfNeeded() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.testEnvironment == true {
            populateMeetingCodeUITextField(with: StubMeetingVars.MeetingCode.rawValue)
            participantNameTextField.text = ParticipantJoinMeetingViewController.randomNameForTestEnvironment()
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

    public func joinMeeting() {
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
        navigationController?.pushViewController(ParticipantLobbyViewController(), animated: false)
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

    private static func randomNameForTestEnvironment() -> String {
        let names = [
            "Sabrina",
            "Brent",
            "Thu",
            "Granville",
            "Daryl",
            "Sommer",
            "Shelby",
            "Kathline",
            "Kathrin",
            "Tiesha",
            "Lavada",
            "Arvilla",
            "Ginny",
            "Lucius",
            "Betsy",
            "Kandy",
            "Ione",
            "Francina",
            "Raina",
            "Glendora",
            "Deandra",
            "Earl",
            "Gladis",
            "Sheena",
            "Brittney",
            "Carol",
            "Lezlie",
            "Santa",
            "Anastacia",
            "Cristin",
            "Shelba",
            "Jeanne",
            "Georgeanna",
            "Eneida",
            "Jame",
            "Senaida",
            "Marcelo",
            "Gabriela",
            "Ouida",
            "Shasta",
            "Adella",
            "Roselia",
            "Corina",
            "Dewey",
            "Bryon",
            "Devora",
            "Afton",
            "Lorette",
            "Francene",
            "Sharen"]

        let index = Int(arc4random_uniform(UInt32(names.count)))
        return names[index]
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
