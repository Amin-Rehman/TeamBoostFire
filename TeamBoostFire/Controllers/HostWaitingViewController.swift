//
//  HostWaitingViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class HostWaitingViewController: UIViewController {
    @IBOutlet weak var meetingCodeLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var childContainerView: UIView!

    var hostWaitingTableViewController = HostWaitingTableViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        hostWaitingTableViewController.view.frame = childContainerView.bounds;
        hostWaitingTableViewController.willMove(toParent: self)
        childContainerView.addSubview(hostWaitingTableViewController.view)
        self.addChild(hostWaitingTableViewController)
        hostWaitingTableViewController.didMove(toParent: self)

        activityIndicatorView.startAnimating()
        let meetingIdentifier = CoreServices.shared.meetingIdentifier
        meetingCodeLabel.text = meetingIdentifier

        CoreServices.shared.subscribeToParticipantChangesList()

    }

    @IBAction func startMeetingClicked(_ sender: Any) {
    }
}
