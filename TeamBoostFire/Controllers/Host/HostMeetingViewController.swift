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

    var hostInMeetingTableViewController = HostInMeetingTableViewController()
    var currentSpeakerIndex = 0

    var speakerControllerService: SpeakerControllerService?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpeakerControllerService()
        setupAgendaQuestion()
        setupChildTableViewController()
        updateUIWithSpeakerOrder()
    }

    private func setupSpeakerControllerService() {
        guard let meetingParams = CoreServices.shared.meetingParams else {
            assertionFailure("Unable to retrieve meeting params")
            return
        }

        speakerControllerService = SpeakerControllerService(meetingParams: meetingParams,
                                                            orderObserver: self)
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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func speakingOrderUpdated() {
        updateUIWithSpeakerOrder()
    }


}
