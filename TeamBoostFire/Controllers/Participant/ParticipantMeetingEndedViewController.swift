//
//  ParticipantMeetingEndedViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 10.06.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit
import Lottie

class ParticipantMeetingEndedViewController: UIViewController {

    @IBOutlet weak var dayNightAnimationView: AnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()

        dayNightAnimationView.play()
        dayNightAnimationView.loopMode = .loop
        navigationController?.setNavigationBarHidden(true,
                                                     animated: true)
    }

    @IBAction func finishTapped(_ sender: Any) {
        navigationController?.dismiss(animated: true,
                                      completion: nil)
    }

}
