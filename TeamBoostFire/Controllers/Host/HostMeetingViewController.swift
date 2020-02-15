//
//  HostMeetingViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

typealias SpeakingFactor = Float

class HostMeetingViewController: UIViewController {
    @IBOutlet weak var childContainerView: UIView!
    @IBOutlet weak var agendaQuestionLabel: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeElapsedProgressView: UIProgressView!

    private var totalMeetingTimeInSeconds = 0
    private var totalMeetingTimeString = String()

    var hostInMeetingTableViewController = HostInMeetingTableViewController()
    var currentSpeakerIndex = 0

    var hostControllerService: HostMeetingControllerService?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)

        setupChildTableViewController()

        setupInitialElapsedMeetingTimeRatio()
        setupAgendaQuestion()
        updateUIWithSpeakerOrder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let notificationName = Notification.Name(AppNotifications.meetingSecondTicked.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(meetingActiveSecondDidTick(notification:)),
                                               name: notificationName, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func meetingActiveSecondDidTick(notification: NSNotification) {
        guard let activeMeetingTime = hostControllerService?.storage.activeMeetingTime else {
            assertionFailure("host controller service not found")
            return
        }

        let timeElapsedString = activeMeetingTime.minutesAndSecondsPrettyString()
        let timeElapsedRatioString = timeElapsedString + "/" + totalMeetingTimeString
        timeElapsedLabel?.text = timeElapsedRatioString

    }

    private func setupInitialElapsedMeetingTimeRatio() {
        guard let meetingParams = HostCoreServices.shared.meetingParams else {
            assertionFailure("Unable to retrieve meeting params")
            return
        }
        let meetingTimeInMinutes = meetingParams.meetingTime
        totalMeetingTimeInSeconds = meetingTimeInMinutes * 60
        totalMeetingTimeString = totalMeetingTimeInSeconds.minutesAndSecondsPrettyString()
        let initialTimeElapsedString = "00:00/" + totalMeetingTimeString
        timeElapsedLabel?.text = initialTimeElapsedString
        timeElapsedProgressView.progress = 0.0
    }

    private func setupAgendaQuestion() {
        let meetingParams = HostCoreServices.shared.meetingParams
        guard let agenda = meetingParams?.agenda else {
            assertionFailure("Unable to retrieve agenda from meeting params")
            return
        }

        agendaQuestionLabel.text = agenda
    }

    private func setupChildTableViewController() {
        assert(hostControllerService != nil, "Speaker controller service is not instantiated")
        hostInMeetingTableViewController.view.frame = childContainerView.bounds;
        hostInMeetingTableViewController.willMove(toParent: self)
        childContainerView.addSubview(hostInMeetingTableViewController.view)
        self.addChild(hostInMeetingTableViewController)
        hostInMeetingTableViewController.didMove(toParent: self)
        hostInMeetingTableViewController.hostControllerService = hostControllerService
        // FIXME
        hostControllerService?.speakerSpeakingTimeUpdater.secondTickObserver = hostInMeetingTableViewController
    }

    private func updateUIWithSpeakerOrder() {
        hostInMeetingTableViewController.updateTableViewWithSpeakerOrder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    @IBAction func endMeetingTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "End Meeting",
                                                message: "Would you like to end meeting?",
                                                preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // TODO: Ignore
        }
        alertController.addAction(cancelAction)

        let OKAction = UIAlertAction(title: "OK", style: .default) { _ in
            AnalyticsService.shared.hostMeetingEnded()
            HostCoreServices.shared.endMeeting()

            self.hostControllerService?.endMeeting()
            HostSaveMeetingStatsToCoreUseCase.perform(
                meetingLengthSeconds: self.hostControllerService!.storage.activeMeetingTime,
                hostControllerService: self.hostControllerService)

            let hostEndMeetingStatsViewController = HostEndMeetingStatsViewController()
            self.navigationController?.pushViewController(hostEndMeetingStatsViewController,
                                                          animated: true)
        }
        alertController.addAction(OKAction)

        present(alertController, animated: true)
    }


    @IBAction func goToNextParticipantTapped(_ sender: Any) {
        hostControllerService?.speakerIsDone()
    }

    @IBAction func haveYourSayTapped(_ sender: Any) {
        self.hostControllerService?.stopParticipantSpeakingSessions()
        HostCoreServices.shared.setModeratorControlState(controlState: true)
        self.navigationController?.popViewController(animated: true)
    }
}

extension HostMeetingViewController: SpeakerControllerOrderObserver {
    func speakingOrderUpdated(totalSpeakingRecord: [ParticipantId : SpeakingTime]) {
        // Update speaking factor in HostInMeetingTableViewController
        hostInMeetingTableViewController.participantIdSpeakingFactorMap =
            SpeakerFactorable.mapToSpeakingFactor(from: totalSpeakingRecord)
        updateUIWithSpeakerOrder()
    }
}

struct SpeakerFactorable {
    /**
     Get speaking factor from the total speaking record
     Use to calculate the progress view in the cell view
     */
    public static func mapToSpeakingFactor(from totalSpeakingRecord: [ParticipantId : SpeakingTime])
        -> [ParticipantId : SpeakingFactor] {

            // Add up all the speaking times
            let allSpeakingTimesArray = Array(totalSpeakingRecord.values)
            let totalSpeakingTime = allSpeakingTimesArray.reduce(0, +)


            let allParticipantIds = Array(totalSpeakingRecord.keys)
            var participantIdSpeakingFactors = [ParticipantId : SpeakingFactor]()

            for participantId in allParticipantIds {
               let participantSpeakingTime = totalSpeakingRecord[participantId]
                let participantSpeakingFactor = Float(participantSpeakingTime!) / Float(totalSpeakingTime)
                participantIdSpeakingFactors[participantId] = participantSpeakingFactor
            }

            return participantIdSpeakingFactors

    }

}
