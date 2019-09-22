//
//  ParticipantMainViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 18.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit
import Lottie

@objc protocol ViewControllerReactable {
    func addParticipantReactionViewController()
    func registerReactionGestures()
    @objc func handleGesture(gesture: UISwipeGestureRecognizer)
    func playFullScreenAnimation(name: String)
}

class ParticipantMainViewController: UIViewController, ParticipantUpdatable {
    
    @IBOutlet weak var agendaQuestionLabel: UILabel!
    @IBOutlet weak var meetingTimeLabel: UILabel!
    @IBOutlet weak var currentSpeakerLabel: UILabel!
    @IBOutlet weak var gameControllerView: UIView!
    @IBOutlet weak var fullScreenAnimaionView: AnimationView!
    
    private weak var selfSpeakerViewController: ParticipantSelfSpeakerViewController?
    
    private var allParticipants = [Participant]()
    var participantGameControllerViewController = ParticipantGameControllerViewController()
    var participantReactionViewController = ParticipantReactionViewController()
    private var participantControllerService: ParticipantControllerService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addParticipantReactionViewController()
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
        registerReactionGestures()
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
    @objc private func meetingStateDidChange(notification: NSNotification) {
        let meetingState = notification.object as! MeetingState
        if meetingState == .ended {
            navigationController?.pushViewController(ParticipantMeetingEndedViewController(),
                                                     animated: true)
        }
    }
}

// MARK: - ViewControllerReactable
extension ParticipantMainViewController: ViewControllerReactable {

    internal func registerReactionGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }

    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            playFullScreenAnimation(name: "agree")
        } else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            playFullScreenAnimation(name: "disagree")
        } else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
            playFullScreenAnimation(name: "celebrate")
        } else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            playFullScreenAnimation(name: "curious")
        }
    }

    internal func playFullScreenAnimation(name: String) {
        if !fullScreenAnimaionView.isAnimationPlaying {
            fullScreenAnimaionView.isHidden = false
            fullScreenAnimaionView.animation = Animation.named(name)
            fullScreenAnimaionView.play { _ in
                self.fullScreenAnimaionView.isHidden = true
            }
        }
    }

    internal func addParticipantReactionViewController() {
        participantReactionViewController.view.frame = gameControllerView.bounds;
        participantReactionViewController.willMove(toParent: self)
        gameControllerView.addSubview(participantReactionViewController.view)
        self.addChild(participantReactionViewController)
        participantReactionViewController.didMove(toParent: self)
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
