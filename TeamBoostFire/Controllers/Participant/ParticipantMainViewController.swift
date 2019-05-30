//
//  ParticipantMainViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 18.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class ParticipantMainViewController: UIViewController {

    @IBOutlet weak var agendaQuestionLabel: UILabel!
    @IBOutlet weak var meetingTimeLabel: UILabel!

    @IBOutlet weak var speakerSpeakingTimeLabel: UILabel!
    @IBOutlet weak var currentSpeakerLabel: UILabel!
    @IBOutlet weak var speakingOrderLabel: UILabel!

    private var secondTickTimer: Timer?
    private var secondTimerCountForParticipant = 0
    private var secondTimerCountForMeeting = 0
    private var currentSpeakerMaxTalkTime: Int?

    private var speakerOrder: [String]?
    private var allParticipants = [Participant]()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let guardedSpeakerOrder = ParticipantCoreServices.shared.speakerOrder else {
            assertionFailure("Unable to load speaker order")
            return
        }
        speakerOrder = guardedSpeakerOrder
        secondTimerCountForParticipant = 0
        currentSpeakerMaxTalkTime = ParticipantCoreServices.shared.meetingParams?.maxTalkTime
        setupTopBar()
        updateSpeakingTimerLabel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSpeakerOrderObserver()
        updateUIWithCurrentSpeaker()
        startSecondTickerTimer()
    }

    private func startSecondTickerTimer() {
        secondTickTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                               selector: #selector(secondTicked),
                                               userInfo: nil, repeats: true)
    }

    private func stopSecondTickerTimer() {
        secondTickTimer?.invalidate()
        secondTickTimer = nil
    }

    private func updateSpeakingTimerLabel() {
        let speakingTimeLeft = currentSpeakerMaxTalkTime! - secondTimerCountForParticipant
        let speakingTimeLeftString = speakingTimeLeft.minutesAndSecondsPrettyString()
        speakerSpeakingTimeLabel.text = "Speaker Time left: \(speakingTimeLeftString)"
    }

    private func updateMeetingTimerLabel() {
        guard let meetingTime = ParticipantCoreServices.shared.meetingParams?.meetingTime else {
            assertionFailure("Participant cannot retrieve meeting time")
            return
        }
        let meetingTimeSeconds = meetingTime * 60
        let meetingTimeLeft = meetingTimeSeconds - secondTimerCountForMeeting
        let meetingTimeLeftString = meetingTimeLeft.minutesAndSecondsPrettyString()
        meetingTimeLabel.text = "Meeting Time left: \(meetingTimeLeftString)"
    }

    @objc func secondTicked() {
        secondTimerCountForParticipant = secondTimerCountForParticipant + 1
        secondTimerCountForMeeting = secondTimerCountForMeeting + 1
        updateSpeakingTimerLabel()
        updateMeetingTimerLabel()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //stopSecondTickerTimer()
    }

    private func setupTopBar() {
        guard let agenda = ParticipantCoreServices.shared.meetingParams?.agenda else {
            assertionFailure("No agenda found in CoreServices")
            return
        }
        agendaQuestionLabel.text = agenda
    }

    private func updateUIWithCurrentSpeaker() {
        let order = selfSpeakingOrder()
        let isSpeakerSelf = order == 0

        if isSpeakerSelf {
            let selfSpeakerViewController = ParticipantSelfSpeakerViewController(
                nibName: "ParticipantSelfSpeakerViewController",
                bundle: nil)
            present(selfSpeakerViewController, animated: true, completion: nil)
        } else {
            presentedViewController?.dismiss(animated: true, completion: nil)

            let currentSpeakingParticipant = currentSpeaker()!
            currentSpeakerLabel.text = "Speaker: \(currentSpeakingParticipant.name)"

            // Update self speaking order
            let order = selfSpeakingOrder()
            speakingOrderLabel.text = "Speaking Order: \(order)"
        }
    }

    private func setupSpeakerOrderObserver() {
        let notificationName = Notification.Name(TeamBoostNotifications.speakerOrderDidChange.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(speakerOrderDidChange(notification:)),
                                               name: notificationName, object: nil)
    }

    @objc private func speakerOrderDidChange(notification: NSNotification) {
        speakerOrder = (notification.object as? [String]) ?? []
        secondTimerCountForParticipant = 0
        currentSpeakerMaxTalkTime = ParticipantCoreServices.shared.meetingParams?.maxTalkTime
        updateSpeakingTimerLabel()
        updateUIWithCurrentSpeaker()
    }

    private func setupCurrentSpeakerMaxTalkTimeChangedObserver() {
        let notificationName = Notification.Name(
            TeamBoostNotifications.currentParticipantMaxSpeakingTimeChanged.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(currentSpeakerMaxTalkTimeChanged(notification:)),
                                               name: notificationName, object: nil)
    }

    @objc private func currentSpeakerMaxTalkTimeChanged(notification: NSNotification) {
        currentSpeakerMaxTalkTime = notification.object as? Int ??
            ParticipantCoreServices.shared.meetingParams?.maxTalkTime

    }


    @IBAction func likeButtonTapped(_ sender: Any) {
    }

    @IBAction func continueButtonTapped(_ sender: Any) {
    }

    @IBAction func callForSpeakerTapped(_ sender: Any) {
    }

    private func currentSpeaker() -> Participant? {
        let allParticipants = ParticipantCoreServices.shared.allParticipants!
        let currentSpeakerIdentifier = speakerOrder?.first!

        for participant in allParticipants {
            if participant.id == currentSpeakerIdentifier {
                return participant
            }
        }

        assertionFailure("Current speaker not found")
        return nil
    }

    private func selfSpeakingOrder() -> Int {
        let selfIdentifier = ParticipantCoreServices.shared.selfParticipantIdentifier!
        return speakerOrder!.firstIndex(of: selfIdentifier)!
    }

}
