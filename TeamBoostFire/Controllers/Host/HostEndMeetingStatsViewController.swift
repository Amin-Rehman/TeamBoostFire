//
//  HostEndMeetingStatsViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 07.06.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class HostEndMeetingStatsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true,
                                                          animated: true)
    }

    @IBAction func iAmDoneTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true,
                                           completion: nil)
    }
}
