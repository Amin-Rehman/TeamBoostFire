//
//  HostMeetingViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class HostMeetingViewController: UIViewController, SpeakerControllerOrderObserver {

    @IBOutlet weak var childContainerView: UIView!
    @IBOutlet weak var agendaQuestionLabel: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeElapsedProgressView: UIProgressView!
    
    private var secondTickTimer: Timer?
    private var totalMeetingTimeInSeconds = 0
    private var totalMeetingTimeString = String()

    var hostInMeetingTableViewController = HostInMeetingTableViewController()
    var currentSpeakerIndex = 0
    private var secondTimerCount = 0

    var hostControllerService: HostControllerService?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSpeakerControllerService()
        setupChildTableViewController()

        setupInitialElapsedMeetingTimeRatio()
        setupAgendaQuestion()
        updateUIWithSpeakerOrder()
        startSecondTickerTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSecondTickerTimer()
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

    @objc func secondTicked() {
        secondTimerCount = secondTimerCount + 1
        let timeElapsedString = secondTimerCount.minutesAndSecondsPrettyString()
        let timeElapsedRatioString = timeElapsedString + "/" + totalMeetingTimeString
        timeElapsedLabel?.text = timeElapsedRatioString

        let progressRatio = Float(secondTimerCount) / Float(totalMeetingTimeInSeconds)
        timeElapsedProgressView.progress = progressRatio
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

    private func setupSpeakerControllerService() {
        guard let meetingParams = HostCoreServices.shared.meetingParams else {
            assertionFailure("Unable to retrieve meeting params")
            return
        }

        hostControllerService = HostControllerService(
            meetingParams: meetingParams,
            orderObserver: self)
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
        hostControllerService?.speakerSecondTickObserver = hostInMeetingTableViewController
    }

    private func updateUIWithSpeakerOrder() {
        hostInMeetingTableViewController.tableViewDataSource = HostCoreServices.shared.allParticipants!
        hostInMeetingTableViewController.tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func speakingOrderUpdated() {
        updateUIWithSpeakerOrder()
    }

    @IBAction func endMeetingTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "End Meeting",
                                                message: "Would you like to end meeting?",
                                                preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // TODO: Ignore
        }
        alertController.addAction(cancelAction)

        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // TODO: Cancel meeting
        }
        alertController.addAction(OKAction)

        present(alertController, animated: true)
    }

    @IBAction func goToNextParticipantTapped(_ sender: Any) {
        hostControllerService?.goToNextSpeaker()
    }

}
