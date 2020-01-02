//
//  HostHaveYourSayViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 01.01.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import UIKit

class HostHaveYourSayViewController: UIViewController {
    let hostMeetingViewController: HostMeetingViewController
    let hostControllerService: HostMeetingControllerService
    private let meetingParams: MeetingsParams
    private var totalMeetingTimeString: String

    @IBOutlet weak var agendaQuestionLabel: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!

    init(with meetingParams: MeetingsParams) {
        self.hostMeetingViewController = HostMeetingViewController(nibName: "HostMeetingViewController",
                                                                   bundle: nil)
        self.meetingParams = meetingParams

        let totalMeetingTimeInSeconds = meetingParams.meetingTime * 60
        totalMeetingTimeString = totalMeetingTimeInSeconds.minutesAndSecondsPrettyString()

        self.hostControllerService = HostMeetingControllerService(
            meetingParams: meetingParams,
            orderObserver: self.hostMeetingViewController,
            meetingMode: meetingParams.moderationMode!,
            coreServices: HostCoreServices.shared)

        self.hostMeetingViewController.hostControllerService = self.hostControllerService
        super.init(nibName: "HostHaveYourSayViewController",
                   bundle: nil)
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateMeetingAgenda()
        updateTimeLabel()
    }

    private func updateMeetingAgenda() {
        self.agendaQuestionLabel.text = meetingParams.agenda
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
        updateTimeLabel()
    }

    private func updateTimeLabel() {
        let activeMeetingTime = hostControllerService.storage.activeMeetingTime
        let timeElapsedString = activeMeetingTime.minutesAndSecondsPrettyString()
        let timeElapsedRatioString = timeElapsedString + "/" + totalMeetingTimeString
        timeElapsedLabel?.text = timeElapsedRatioString
    }


    @IBAction func collectIdeasTapped(_ sender: Any) {
        self.hostControllerService.startParticipantSpeakingSessions()
        self.navigationController?.pushViewController(self.hostMeetingViewController, animated: true)
    }
}
