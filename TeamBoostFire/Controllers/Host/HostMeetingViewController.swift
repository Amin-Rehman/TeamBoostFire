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
    @IBOutlet weak var agendaQuestionLabel: UILabel!

    var hostInMeetingTableViewController = HostInMeetingTableViewController()
    var timer: Timer?

    var currentSpeakerIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAgendaQuestion()
        setupChildTableViewController()
        updateUIWithSpeakerOrder()
        setupTimer()
    }

    private func setupAgendaQuestion() {
        let meetingParams = CoreServices.shared.meetingParams
        guard let agenda = meetingParams?.agenda else {
            assertionFailure("Unable to retrieve agenda from meeting params")
            return
        }

        agendaQuestionLabel.text = agenda
    }

    private func setupChildTableViewController() {
        hostInMeetingTableViewController.view.frame = childContainerView.bounds;
        hostInMeetingTableViewController.willMove(toParent: self)
        childContainerView.addSubview(hostInMeetingTableViewController.view)
        self.addChild(hostInMeetingTableViewController)
        hostInMeetingTableViewController.didMove(toParent: self)
    }


    private func updateUIWithSpeakerOrder() {
        hostInMeetingTableViewController.tableViewDataSource = CoreServices.shared.allParticipants!
        hostInMeetingTableViewController.tableView.reloadData()
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
        updateUIWithSpeakerOrder()
    }

}
