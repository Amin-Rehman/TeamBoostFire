//
//  ParticipantMainViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 18.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit
import Lottie

class ParticipantMainViewController: UIViewController, ParticipantUpdatable {
    
    @IBOutlet weak var agendaQuestionLabel: UILabel!
    @IBOutlet weak var meetingTimeLabel: UILabel!
    @IBOutlet weak var currentSpeakerLabel: UILabel!

    private weak var selfSpeakerViewController: ParticipantSelfSpeakerViewController?
    
    private var allParticipants = [Participant]()
    var participantReactionViewController = ParticipantReactionViewController()
    private var participantControllerService: ParticipantControllerService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true,
                                                     animated: true)
        let meetingParams = ParticipantCoreServices.shared.meetingParams
        self.participantControllerService = ParticipantControllerService(with: meetingParams!,
                                                                         timesUpdatedObserver: self)
        updateMeetingTimerLabel(with: (meetingParams?.meetingTime)!)
        setupTopBar()
        let notificationName = Notification.Name(TeamBoostNotifications.meetingStateDidChange.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(meetingStateDidChange(notification:)),
                                               name: notificationName, object: nil)
    }

    private func setupTopBar() {
        assert(self.participantControllerService != nil)
        guard let agenda = self.participantControllerService?.meetingParams.agenda else {
            assertionFailure("No agenda found in CoreServices")
            return
        }
        agendaQuestionLabel.text = agenda
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        participantControllerService?.participantTimeUpdateable = self
        updateUIWithCurrentSpeaker(with: participantControllerService?.speakerOrder ?? [])
        super.viewDidAppear(animated)
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

    }
}


// MARK: - ParticipantMainViewController UI Updates
extension ParticipantMainViewController {
    func updateTime(participantLeftSpeakingTime: Int, meetingLeftTime: Int) {
        selfSpeakerViewController?.updateTime(participantLeftSpeakingTime: participantLeftSpeakingTime,
                                              meetingLeftTime: meetingLeftTime)
        updateMeetingTimerLabel(with: meetingLeftTime)
    }

    func updateSpeakingOrder(speakingOrder: [String]) {
        updateUIWithCurrentSpeaker(with: speakingOrder)
    }

    private func updateMeetingTimerLabel(with meetingTimeLeft: Int) {
        let meetingTimeLeftString = meetingTimeLeft.minutesAndSecondsPrettyString()
        meetingTimeLabel.text = "Meeting Time left: \(meetingTimeLeftString)"
    }

    private func updateUIWithCurrentSpeaker(with speakingOrder: [String]) {
        let order = selfSpeakingOrder(with: speakingOrder)
        let isSpeakerSelf = order == 0

        if isSpeakerSelf {
            let selfSpeakerVC = ParticipantSelfSpeakerViewController(
                nibName: "ParticipantSelfSpeakerViewController",
                bundle: nil)
            selfSpeakerVC.modalPresentationStyle = .overFullScreen
            present(selfSpeakerVC, animated: true, completion: {
                print("ALOG: Self Participant View presented")
                self.selfSpeakerViewController = selfSpeakerVC
            })
        } else {
            guard let selfSpeakerVC = selfSpeakerViewController else {
                return
            }
            selfSpeakerVC.dismiss(animated: true, completion: {
                print("ALOG: Self Participant View dismissed")
                let currentSpeakingParticipant = self.currentSpeaker(with: speakingOrder)
                self.currentSpeakerLabel.text = "\(currentSpeakingParticipant!.name) is speaking"
            })
        }
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
