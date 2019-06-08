//
//  WelcomeViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 08.06.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            toggleTestMode()
        }
    }

    func toggleTestMode() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let currentlyInTestMode = appDelegate.testEnvironment
        if currentlyInTestMode {
            appDelegate.testEnvironment = false
        } else {
            appDelegate.testEnvironment = true
        }

    }
}
