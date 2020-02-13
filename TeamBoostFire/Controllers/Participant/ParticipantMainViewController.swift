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
//        participantControllerService?.participantTimeUpdateable = self
        updateUIWithCurrentSpeaker(with: participantControllerService?.speakerOrder ?? [])
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
        }
    }


    @IBAction func likeButtonTapped(_ sender: Any) {
        // TODO: Implement
    }

    @IBAction func callSpeakerTapped(_ sender: Any) {
        ParticipantCoreServices.shared.registerCallToSpeaker()
    }
}

// MARK: - ParticipantMainViewController UI Updates
extension ParticipantMainViewController {

    private func updateMeetingTimerLabel(with meetingTimeLeft: Int) {
        let meetingTimeLeftString = meetingTimeLeft.minutesAndSecondsPrettyString()
        meetingTimeLabel.text = "Meeting Time left: \(meetingTimeLeftString)"
    }

    private func updateUIWithCurrentSpeaker(with speakingOrder: [String]) {
        let order = selfSpeakingOrder(with: speakingOrder)
        let isSpeakerSelf = order == 0
        print("ALOG: isSpeakerSelf = \(isSpeakerSelf)")
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

    private func selfSpeakingOrder(with speakerOrder: [String]) -> Int {
        guard let selfIdentifier = self.participantControllerService?.selfIdentifier else {
            fatalError("Self identifier not found for participant")
        }
        return speakerOrder.firstIndex(of: selfIdentifier) ?? -1
    }
}

extension ParticipantMainViewController: ParticipantSpeakerTracker {
    func updateTime(participantLeftSpeakingTime: Int, meetingLeftTime: Int) {
        updateMeetingTimerLabel(with: meetingLeftTime)
    }

    func updateSpeakingOrder(speakingOrder: [String]) {
        updateUIWithCurrentSpeaker(with: speakingOrder)
    }
}

extension ParticipantMainViewController: ModeratorSpeakerTracker {

    func moderatorStartedSpeaking() {
        print(" ALOG: Moderator Started Speaking")
    }

    func moderatorStoppedSpeaking() {
        print(" ALOG: Moderator Started stopped")
    }
}
