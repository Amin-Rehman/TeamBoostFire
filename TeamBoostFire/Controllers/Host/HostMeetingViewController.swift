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

    override func viewDidLoad() {
        super.viewDidLoad()
        hostInMeetingTableViewController.view.frame = childContainerView.bounds;
        hostInMeetingTableViewController.willMove(toParent: self)
        childContainerView.addSubview(hostInMeetingTableViewController.view)
        self.addChild(hostInMeetingTableViewController)
        hostInMeetingTableViewController.didMove(toParent: self)

        let notificationName = Notification.Name(TeamBoostNotifications.activeSpeakerDidChange.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(activeSpeakerDidChange(notification:)),
                                               name: notificationName, object: nil)
    }

    @objc private func activeSpeakerDidChange(notification: NSNotification) {
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
