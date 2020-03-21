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

    @IBOutlet weak var iAmDoneButton: UIButton!

    @IBOutlet weak var fireworksView: AnimationView!
    @IBOutlet weak var meetingStateAnimationView: AnimationView!

    @IBOutlet weak var feedbackStackView: UIStackView!

    private var currentlyDisplayedSpeakingOrder: [String]?
    private var allParticipants = [Participant]()

    var participantReactionViewController = ParticipantReactionViewController()
    public var participantControllerService: ParticipantControllerService?
    private var previousInMeetingState = ParticipantControllerInMeetingState.unknown

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
        setupReactionStackView()
        let notificationName = Notification.Name(TeamBoostNotifications.meetingStateDidChange.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(meetingStateDidChange(notification:)),
                                               name: notificationName, object: nil)

        fireworksView.isHidden = true
    }

    private func registerGestureRecognizers() {
        let leftSwipe = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(likedRegistered(_:)))
        leftSwipe.direction = .right
        self.view.addGestureRecognizer(leftSwipe)

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(callSpeakerRegistered))
        doubleTap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTap)
    }

    private func unregisterGestureRecognizers() {
        guard let allGestureRecognisers = self.view.gestureRecognizers else { return  }
        for gestureRecogniser in allGestureRecognisers {
            self.view.removeGestureRecognizer(gestureRecogniser)
        }
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

    private func setupReactionStackView() {
        let callSpeakerReactionViewController =
            LottieLabelViewController(animationName: "double-tap",
                                      title: "Call Speaker")

        let likeReactionViewController =
            LottieLabelViewController(animationName: "swipe-right",
                                      title: "Like")

        feedbackStackView.addArrangedSubview(callSpeakerReactionViewController.view)
        feedbackStackView.addArrangedSubview(likeReactionViewController.view)

        //Then, add the child to the parent
        self.addChild(callSpeakerReactionViewController)
        self.addChild(likeReactionViewController)

        // Finally, notify the child that it was moved to a parent
        callSpeakerReactionViewController.didMove(toParent: self)
        likeReactionViewController.didMove(toParent: self)
    }

    @objc private func meetingStateDidChange(notification: NSNotification) {
        let meetingState = notification.object as! MeetingState
        if meetingState == .ended {
            navigationController?.pushViewController(ParticipantMeetingEndedViewController(),
                                                     animated: true)
            NotificationCenter.default.removeObserver(self)
        }
    }

    @objc func likedRegistered(_ sender:UISwipeGestureRecognizer) {
        fireworksView.isHidden = false
        fireworksView.play { (finished) in
            self.fireworksView.isHidden = true
        }
    }

    @objc func callSpeakerRegistered() {
        AnalyticsService.shared.participantCalledSpeaker()
        ParticipantCoreServices.shared.registerCallToSpeaker()

        let alertController = UIAlertController(
            title: "Moderator Called!",
            message: "Moderator has been called. Please wait for your turn to speak.",
            preferredStyle: .alert)
        self.present(alertController, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.00,
                                          qos: .userInteractive) {
                                            alertController.dismiss(animated: true,
                                                                    completion: nil)
            }
        }
    }

    @IBAction func iAmDoneTapped(_ sender: Any) {
        AnalyticsService.shared.participantIsDone()
        ParticipantCoreServices.shared.registerParticipantIsDoneInterrupt()
    }
}

// MARK: - ParticipantMainViewController UI Updates
extension ParticipantMainViewController {

    private func updateMeetingTimerLabel(with meetingTimeLeft: Int) {
        let meetingTimeLeftString = meetingTimeLeft.minutesAndSecondsPrettyString()
        meetingTimeLabel.text = "Meeting Time left: \(meetingTimeLeftString)"
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

        let isStateTransition = !previousInMeetingState.typeCompare(target: state)
        previousInMeetingState = state

        let crossFadeDuration = Double(0.5)

        switch state {
        case .unknown:
            assertionFailure("Unknown in meeting state")
//            likeButton.isHidden = true
//            callSpeakerButton.isHidden = true

            registerGestureRecognizers()
            feedbackStackView.isHidden = false
            iAmDoneButton.isHidden = true


            currentSpeakerLabel.text = "Unknown"
        case .selfIsSpeaking:
//            likeButton.crossFadeTransition(duration: crossFadeDuration,
//                                           shouldHide: true)
//            callSpeakerButton.crossFadeTransition(duration: crossFadeDuration,
//                                                  shouldHide: true)

            unregisterGestureRecognizers()
            feedbackStackView.crossFadeTransition(duration: crossFadeDuration,
                                                              shouldHide: true)
            iAmDoneButton.crossFadeTransition(duration: crossFadeDuration,
                                              shouldHide: false)
            UIView.transition(with: currentSpeakerLabel,
                 duration: crossFadeDuration,
                  options: .transitionCrossDissolve,
               animations: { [weak self] in
                self?.currentSpeakerLabel.text = "Have your say!"
            }, completion: nil)

            if isStateTransition {
                transitionAnimation(animationName: "you_are_presenting")
            }

        case .anotherParticipantIsSpeaking(let participantName):
//            likeButton.isHidden = false
//            callSpeakerButton.isHidden = false
            iAmDoneButton.isHidden = true
//            likeButton.crossFadeTransition(duration: crossFadeDuration,
//                                           shouldHide: false)
//            callSpeakerButton.crossFadeTransition(duration: crossFadeDuration,
//                                                  shouldHide: false)

            registerGestureRecognizers()
            feedbackStackView.crossFadeTransition(duration: crossFadeDuration,
                                                              shouldHide: false)
            iAmDoneButton.crossFadeTransition(duration: crossFadeDuration,
                                              shouldHide: true)

            UIView.transition(with: currentSpeakerLabel,
                 duration: crossFadeDuration,
                  options: .transitionCrossDissolve,
               animations: { [weak self] in
                self?.currentSpeakerLabel.text = "\(participantName) is Speaking"
            }, completion: nil)

            if isStateTransition {
                transitionAnimation(animationName: "someone_is_speaking")
            }

        case .moderatorIsSpeaking:
//            likeButton.crossFadeTransition(duration: crossFadeDuration,
//                                           shouldHide: true)
//            callSpeakerButton.crossFadeTransition(duration: crossFadeDuration,
//                                                  shouldHide: true)

            unregisterGestureRecognizers()
            feedbackStackView.crossFadeTransition(duration: crossFadeDuration,
                                                              shouldHide: true)
            iAmDoneButton.crossFadeTransition(duration: crossFadeDuration,
                                              shouldHide: true)

            UIView.transition(with: currentSpeakerLabel,
                 duration: crossFadeDuration,
                  options: .transitionCrossDissolve,
               animations: { [weak self] in
                self?.currentSpeakerLabel.text = "The Moderator is Speaking"
            }, completion: nil)

            if isStateTransition {
                transitionAnimation(animationName: "brain_storm")
            }
        }
    }

    private func transitionAnimation(animationName: String) {
        self.meetingStateAnimationView.stop()
        self.meetingStateAnimationView.animation = Animation.named(animationName)
        self.meetingStateAnimationView.play()
        self.meetingStateAnimationView.loopMode = .loop
    }

//        let animationDuration = 0.5
//
//        meetingStateAnimationView.fadeOut(duration: animationDuration) { _ in
//            self.meetingStateAnimationView.stop()
//            self.meetingStateAnimationView.animation = Animation.named(animationName)
//            self.meetingStateAnimationView.play()
//            self.meetingStateAnimationView.loopMode = .loop
//            self.meetingStateAnimationView.fadeIn(duration: animationDuration, completion: nil)
//        }
//    }

}

extension ParticipantMainViewController: RemainingMeetingTimeUpdater {
    func updateTime(meetingLeftTime: Int) {
        updateMeetingTimerLabel(with: meetingLeftTime)
    }
}

extension UIView {
    func crossFadeTransition(duration: Double,
                      shouldHide: Bool) {
        UIView.transition(with: self,
             duration: duration,
              options: .transitionCrossDissolve,
           animations: {
            self.isHidden = shouldHide
        }, completion: nil)
    }
}

extension UIView {

  /**
  Fade in a view with a duration

  - parameter duration: custom animation duration
  */
    func fadeIn(duration: Double, completion: ((Bool) -> Void)?) {
        UIView.animate(
            withDuration: duration,
            animations: {
            self.alpha = 1.0
        }, completion: completion)
    }

  /**
  Fade out a view with a duration

  - parameter duration: custom animation duration
  */
  func fadeOut(duration: Double, completion: ((Bool) -> Void)?) {
      UIView.animate(
          withDuration: duration,
          animations: {
          self.alpha = 0.1
      }, completion: completion)
  }
}
