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

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.startAnimating()
        let meetingIdentifier = CoreServices.shared.meetingIdentifier
        meetingCodeLabel.text = meetingIdentifier

    }

    @IBAction func startMeetingClicked(_ sender: Any) {
    }
}
