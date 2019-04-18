//
//  ParticipantMainViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 18.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class ParticipantMainViewController: UIViewController {
    @IBOutlet weak var fooLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let notificationName = Notification.Name(TeamBoostNotifications.activeSpeakerDidChange.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(activeSpeakerDidChange(notification:)),
                                               name: notificationName, object: nil)

    }

    @objc private func activeSpeakerDidChange(notification: NSNotification) {
        let activeSpeakerIdentifier = notification.object as! String        
        fooLabel.text = activeSpeakerIdentifier
    }

}
