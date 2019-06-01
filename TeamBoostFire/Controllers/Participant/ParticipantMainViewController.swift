//
//  ParticipantMainViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 18.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class ParticipantMainViewController: UIViewController, ParticipantUpdatable {

    @IBOutlet weak var agendaQuestionLabel: UILabel!
    @IBOutlet weak var meetingTimeLabel: UILabel!
    @IBOutlet weak var speakerSpeakingTimeLabel: UILabel!
    @IBOutlet weak var currentSpeakerLabel: UILabel!

    private var allParticipants = [Participant]()

    private var participantControllerService: ParticipantControllerService?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopBar()
        let meetingParams = ParticipantCoreServices.shared.meetingParams
        self.participantControllerService = ParticipantControllerService(with: meetingParams!,
                                                                         timesUpdatedObserver: self)
        updateSpeakingTimerLabel(with: (meetingParams?.maxTalkTime)!)
        updateMeetingTimerLabel(with: (meetingParams?.meetingTime)!)
    }

    private func setupTopBar() {
        guard let agenda = ParticipantCoreServices.shared.meetingParams?.agenda else {
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

    func updateTime(participantLeftSpeakingTime: Int, meetingLeftTime: Int) {
        updateSpeakingTimerLabel(with: participantLeftSpeakingTime)
        updateMeetingTimerLabel(with: meetingLeftTime)
    }

    func updateSpeakingOrder(speakingOrder: [String]) {
        updateUIWithCurrentSpeaker(with: speakingOrder)
    }

    private func updateSpeakingTimerLabel(with speakingTimeLeft: Int) {
        let speakingTimeLeftString = speakingTimeLeft.minutesAndSecondsPrettyString()
        speakerSpeakingTimeLabel.text = "Speaker Time left: \(speakingTimeLeftString)"
    }

    private func updateMeetingTimerLabel(with meetingTimeLeft: Int) {
        let meetingTimeLeftString = meetingTimeLeft.minutesAndSecondsPrettyString()
        meetingTimeLabel.text = "Meeting Time left: \(meetingTimeLeftString)"
    }

    private func updateUIWithCurrentSpeaker(with speakingOrder: [String]) {
        let order = selfSpeakingOrder(with: speakingOrder)
        let isSpeakerSelf = order == 0

        if isSpeakerSelf {
            guard let controllerService = participantControllerService else {
                fatalError("Unable to find controller service")
            }

            let selfSpeakerViewController =
                ParticipantSelfSpeakerViewController(nibName: "ParticipantSelfSpeakerViewController",
                participantControllerService: controllerService)

            present(selfSpeakerViewController, animated: true, completion: nil)
        } else {
            presentedViewController?.dismiss(animated: true, completion: nil)

            let currentSpeakingParticipant = currentSpeaker(with: speakingOrder)
            currentSpeakerLabel.text = "\(currentSpeakingParticipant!.name) is speaking"
        }
    }

    @IBAction func likeButtonTapped(_ sender: Any) {
    }

    @IBAction func continueButtonTapped(_ sender: Any) {
    }

    @IBAction func callForSpeakerTapped(_ sender: Any) {
    }

    private func currentSpeaker(with speakingOrder: [String]) -> Participant? {
        guard let allParticipants = ParticipantCoreServices.shared.allParticipants else {
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
        guard let selfIdentifier = ParticipantCoreServices.shared.selfParticipantIdentifier else {
            fatalError("Self identifier not found for participant")
        }
        return speakerOrder.firstIndex(of: selfIdentifier) ?? -1
    }

}
