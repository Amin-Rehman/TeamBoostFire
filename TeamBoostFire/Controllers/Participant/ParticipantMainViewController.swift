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

    private var speakerOrder = [String]()
    private var allParticipants = [Participant]()

    override func viewDidLoad() {
        super.viewDidLoad()
        speakerOrder = ParticipantCoreServices.shared.speakerOrder ?? []
        secondTimerCountForParticipant = 0
        setupTopBar()
        updateSpeakingTimerLabel()
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
        let timeElapsedString = secondTimerCountForParticipant.minutesAndSecondsPrettyString()
        speakerSpeakingTimeLabel.text = timeElapsedString
    }

    private func updateMeetingTimerLabel() {
        let timeElapsedString = secondTimerCountForMeeting.minutesAndSecondsPrettyString()
        meetingTimeLabel.text = timeElapsedString
    }

    @objc func secondTicked() {
        secondTimerCountForParticipant = secondTimerCountForParticipant + 1
        secondTimerCountForMeeting = secondTimerCountForMeeting + 1
        updateSpeakingTimerLabel()
        updateMeetingTimerLabel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSpeakerOrderObserver()
        updateUIWithCurrentSpeaker()
        startSecondTickerTimer()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopSecondTickerTimer()
    }

    private func setupTopBar() {
        guard let agenda = ParticipantCoreServices.shared.meetingParams?.agenda else {
            assertionFailure("No agenda found in CoreServices")
            return
        }
        agendaQuestionLabel.text = agenda
    }

    private func updateUIWithCurrentSpeaker() {
        let selfSpeakingOrder = selfSpeakingOrder()
        let isSpeakerSelf = selfSpeakingOrder == 0

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
            let selfSpeakingOrder = selfSpeakingOrder()
            speakingOrderLabel.text = "Speaking Order: \(selfSpeakingOrder)"
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
        updateSpeakingTimerLabel()
        updateUIWithCurrentSpeaker()
    }

    @IBAction func likeButtonTapped(_ sender: Any) {
    }

    @IBAction func continueButtonTapped(_ sender: Any) {
    }

    @IBAction func callForSpeakerTapped(_ sender: Any) {
    }

    private func currentSpeaker() -> Participant? {
        let allParticipants = ParticipantCoreServices.shared.allParticipants!
        let currentSpeakerIdentifier = speakerOrder.first!

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
        return speakerOrder.firstIndex(of: selfIdentifier)!
    }

}
