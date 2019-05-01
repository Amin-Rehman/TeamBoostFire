//
//  HostMeetingViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class HostMeetingViewController: UIViewController {
    @IBOutlet weak var childContainerView: UIView!

    var hostInMeetingTableViewController = HostInMeetingTableViewController()
    var timer: Timer?

    var currentSpeakerIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildTableViewController()
        setupSpeakerOrderObserver()
        setupInitialSpeakingOrder()
        setupTimer()
    }

    private func setupChildTableViewController() {
        hostInMeetingTableViewController.view.frame = childContainerView.bounds;
        hostInMeetingTableViewController.willMove(toParent: self)
        childContainerView.addSubview(hostInMeetingTableViewController.view)
        self.addChild(hostInMeetingTableViewController)
        hostInMeetingTableViewController.didMove(toParent: self)
    }

    private func setupSpeakerOrderObserver() {
        let notificationName = Notification.Name(TeamBoostNotifications.speakerOrderDidChange.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(speakerOrderDidChange(notification:)),
                                               name: notificationName, object: nil)
    }

    private func setupInitialSpeakingOrder() {
        var allParticipantIdentifiers = [String]()
        let allParticipants = CoreServices.shared.allParticipants
        for participant in allParticipants! {
            allParticipantIdentifiers.append(participant.id)
        }
        CoreServices.shared.updateSpeakerOrder(with: allParticipantIdentifiers)
    }

    private func setupTimer() {
        let meetingParams = CoreServices.shared.meetingParams
        timer = Timer.scheduledTimer(timeInterval: Double(meetingParams!.maxTalkTime), target: self,
                                     selector: #selector(rotateSpeakerOrder),
                                     userInfo: nil, repeats: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }

    @objc func rotateSpeakerOrder() {
        guard var speakingOrder = CoreServices.shared.speakerOrder else {
            assertionFailure("No speaker order available in CoreServices")
            return
        }
        speakingOrder = speakingOrder.circularRotate()
        CoreServices.shared.updateSpeakerOrder(with: speakingOrder)
    }

    @objc private func speakerOrderDidChange(notification: NSNotification) {
        let activeSpeakerIdentifier = notification.object as! String

        let allParticipants = CoreServices.shared.allParticipants!
        var updatedAllParticipants = [Participant]()
        for participant in allParticipants {
            let updatedParticipant = Participant(id: participant.id,
                                                 name: participant.name,
                                                 isActiveSpeaker: participant.id == activeSpeakerIdentifier)
            updatedAllParticipants.append(updatedParticipant)
        }

        CoreServices.shared.allParticipants = updatedAllParticipants
        hostInMeetingTableViewController.tableViewDataSource = updatedAllParticipants
        hostInMeetingTableViewController.tableView.reloadData()

    }
}
