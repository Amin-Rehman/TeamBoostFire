//
//  ParticipantMainViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 18.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit
import Lottie

class ParticipantMainViewController: UIViewController {

    @IBOutlet weak var agendaQuestionLabel: UILabel!
    @IBOutlet weak var meetingTimeLabel: UILabel!
    @IBOutlet weak var currentSpeakerLabel: UILabel!

    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var callSpeakerButton: UIButton!
    @IBOutlet weak var iAmDoneButton: UIButton!

    private var currentlyDisplayedSpeakingOrder: [String]?
    private var allParticipants = [Participant]()

    var participantReactionViewController = ParticipantReactionViewController()
    public var participantControllerService: ParticipantControllerService?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let controllerService = self.participantControllerService else {
            assertionFailure("No participant controller service available")
            return
        }

        navigationController?.setNavigationBarHidden(true,
                                                     animated: true)

        updateMeetingTimerLabel(with: (controllerService.meetingTime))
        setupTopBar()
        let notificationName = Notification.Name(TeamBoostNotifications.meetingStateDidChange.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(meetingStateDidChange(notification:)),
                                               name: notificationName, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setupTopBar() {
        assert(self.participantControllerService != nil)
        guard let agenda = self.participantControllerService?.meetingParams.agenda else {
            assertionFailure("No agenda found in CoreServices")
            return
        }
        agendaQuestionLabel.text = agenda
    }

    @objc private func meetingStateDidChange(notification: NSNotification) {
        let meetingState = notification.object as! MeetingState
        if meetingState == .ended {
            navigationController?.pushViewController(ParticipantMeetingEndedViewController(),
                                                     animated: true)
            NotificationCenter.default.removeObserver(self)
        }
    }


    @IBAction func likeButtonTapped(_ sender: Any) {
        // TODO: Implement
    }

    @IBAction func callSpeakerTapped(_ sender: Any) {
        ParticipantCoreServices.shared.registerCallToSpeaker()
    }

    @IBAction func iAmDoneTapped(_ sender: Any) {
        ParticipantCoreServices.shared.registerParticipantIsDoneInterrupt()
    }
}

// MARK: - ParticipantMainViewController UI Updates
extension ParticipantMainViewController {

    private func updateMeetingTimerLabel(with meetingTimeLeft: Int) {
        let meetingTimeLeftString = meetingTimeLeft.minutesAndSecondsPrettyString()
        meetingTimeLabel.text = "Meeting Time left: \(meetingTimeLeftString)"
    }

    private func updateUIWithCurrentSpeaker(with speakingOrder: [String]) {
        print("ALOG: Participant update UI speaker order")
//        currentlyDisplayedSpeakingOrder = speakingOrder
//        let order = selfSpeakingOrder(with: speakingOrder)
//        let isSpeakerSelf = order == 0
    }

    private func currentSpeaker(with speakingOrder: [String]) -> Participant? {
        guard let allParticipants = self.participantControllerService?.allParticipants else {
            assertionFailure("Unable to retrieve all participants")
            return nil
        }

        guard let currentSpeakerIdentifier = speakingOrder.first else {
            assertionFailure("Unable to retrieve currentSpeakerIdentifier")
            return nil
        }

        for participant in allParticipants {
            if participant.id == currentSpeakerIdentifier {
                return participant
            }
        }

        assertionFailure("Current speaker not found")
        return nil
    }

}

extension ParticipantMainViewController: ParticipantControllerInMeetingStateObserver {

    func participantInMeetingStateDidChange(state: ParticipantControllerInMeetingState) {
        if !self.isViewLoaded {
            return
        }

        switch state {
        case .unknown:
            assertionFailure("Unknown in meeting state")
            likeButton.isHidden = true
            callSpeakerButton.isHidden = true
            iAmDoneButton.isHidden = true
            currentSpeakerLabel.text = "Unknown"
        case .selfIsSpeaking:
            likeButton.isHidden = true
            callSpeakerButton.isHidden = true
            iAmDoneButton.isHidden = false
            UIView.transition(with: currentSpeakerLabel,
                 duration: 0.25,
                  options: .transitionCrossDissolve,
               animations: { [weak self] in
                self?.currentSpeakerLabel.text = "Have your say!"
            }, completion: nil)

        case .anotherParticipantIsSpeaking(let participantName):
            likeButton.isHidden = false
            callSpeakerButton.isHidden = false
            iAmDoneButton.isHidden = true

            UIView.transition(with: currentSpeakerLabel,
                 duration: 0.25,
                  options: .transitionCrossDissolve,
               animations: { [weak self] in
                self?.currentSpeakerLabel.text = "\(participantName) is Speaking"
            }, completion: nil)

        case .moderatorIsSpeaking:
            likeButton.isHidden = true
            callSpeakerButton.isHidden = true
            iAmDoneButton.isHidden = true

            UIView.transition(with: currentSpeakerLabel,
                 duration: 0.25,
                  options: .transitionCrossDissolve,
               animations: { [weak self] in
                self?.currentSpeakerLabel.text = "The Moderator is Speaking"
            }, completion: nil)
        }
    }

    func updateSpeakingOrder(speakingOrder: [String]) {
        /**
         Debouncing on this side, as firebase can potentially (and does) trigger multiple events for the
         speaking order
         */
    }
}

extension ParticipantMainViewController: RemainingMeetingTimeUpdater {
    func updateTime(meetingLeftTime: Int) {
        updateMeetingTimerLabel(with: meetingLeftTime)
    }
}
