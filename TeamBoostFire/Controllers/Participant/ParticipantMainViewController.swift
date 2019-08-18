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
    @IBOutlet weak var lottieAnimationView: AnimationView!
    @IBOutlet weak var gameControllerView: UIView!

    private var allParticipants = [Participant]()
    var participantGameControllerViewController = ParticipantGameControllerViewController()
    var participantReactionViewController = ParticipantReactionViewController()

    private var participantControllerService: ParticipantControllerService?

    @IBAction func likeTapped(_ sender: Any) {
        let animation = Animation.named("lottie_participant_reaction")
        lottieAnimationView.animation = animation
        lottieAnimationView.alpha = 1.0
        lottieAnimationView.play { _ in
            self.lottieAnimationView.alpha = 0.0
        }
    }

    @IBAction func clapTapped(_ sender: Any) {
        let animation = Animation.named("lottie_participant_reaction")
        lottieAnimationView.animation = animation
        lottieAnimationView.alpha = 1.0
        lottieAnimationView.play { _ in
            self.lottieAnimationView.alpha = 0.0
        }
    }
    @IBAction func ideaTapped(_ sender: Any) {
        let animation = Animation.named("lottie_participant_bulb")
        lottieAnimationView.animation = animation
        lottieAnimationView.alpha = 1.0
        lottieAnimationView.play { _ in
            self.lottieAnimationView.alpha = 0.0
        }
    }

    @IBAction func thinkingTapped(_ sender: Any) {
        let animation = Animation.named("lottie_participant_bulb")
        lottieAnimationView.animation = animation
        lottieAnimationView.alpha = 1.0
        lottieAnimationView.play { _ in
            self.lottieAnimationView.alpha = 0.0
        }

    }

    private func addGameController() {

        participantReactionViewController.view.frame = gameControllerView.bounds;
        participantReactionViewController.willMove(toParent: self)
        gameControllerView.addSubview(participantReactionViewController.view)
        self.addChild(participantReactionViewController)
        participantReactionViewController.didMove(toParent: self)


        // participantGameControllerViewController.view.frame = gameControllerView.bounds;
        // participantGameControllerViewController.willMove(toParent: self)
        // gameControllerView.addSubview(participantGameControllerViewController.view)
        // self.addChild(participantGameControllerViewController)
        // participantGameControllerViewController.didMove(toParent: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addGameController()
        navigationController?.setNavigationBarHidden(true,
                                                     animated: true)
        setupTopBar()
        let meetingParams = ParticipantCoreServices.shared.meetingParams
        self.participantControllerService = ParticipantControllerService(with: meetingParams!,
                                                                         timesUpdatedObserver: self)
        updateMeetingTimerLabel(with: (meetingParams?.meetingTime)!)

        let notificationName = Notification.Name(TeamBoostNotifications.meetingStateDidChange.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(meetingStateDidChange(notification:)),
                                               name: notificationName, object: nil)
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


    @objc private func meetingStateDidChange(notification: NSNotification) {
        let meetingState = notification.object as! MeetingState
        if meetingState == .ended {
            navigationController?.pushViewController(ParticipantMeetingEndedViewController(),
                                                                           animated: true)
        }
    }
}
