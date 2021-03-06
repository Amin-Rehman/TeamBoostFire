//
//  WelcomeViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 08.06.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit
import Lottie

class WelcomeViewController: UIViewController {

    @IBOutlet weak var brainStormAnimationView: AnimationView!
    @IBOutlet weak var versionLabel: UILabel!

    func makeAppVersionString() -> String {
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
                return ""
        }
        return "TeamBoost v" + appVersion + "(" + buildNumber + ")"
    }

    func populateVersionLabel() {
        let versionString = makeAppVersionString()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let currentlyInTestMode = appDelegate.testEnvironment
        if currentlyInTestMode {
            versionLabel.text = versionString + "- Test mode"
        } else {
            versionLabel.text = versionString
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        populateVersionLabel()
        brainStormAnimationView.loopMode = .autoReverse
    }

    override func viewDidAppear(_ animated: Bool) {
        brainStormAnimationView.play()
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        let appConfiguration = Config.appConfiguration
        if motion == .motionShake {
            switch appConfiguration {
            case .Debug,
                 .TestFlight:
                toggleTestMode()
            case .AppStore:
                return
            }
        }
    }

    func toggleTestMode() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let currentlyInTestMode = appDelegate.testEnvironment
        let toggledCurrentMode = !currentlyInTestMode

        UserDefaults.standard.setValue(toggledCurrentMode, forKey: testModeKey)
        appDelegate.testEnvironment = toggledCurrentMode

        if let popOverView = Bundle.main.loadNibNamed("PopoverView", owner: self, options: nil)?.first as? UIView {
            popOverView.alpha = 0.0;
            popOverView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)

            self.view.addSubview(popOverView)
            popOverView.center = self.view.center
            UIView.animate(withDuration: 0.5, animations: {
                popOverView.alpha = 1.0
                popOverView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }) { _ in
                // After the popover has appeared
                UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                    popOverView.alpha = 0.0
                }, completion: { _ in
                    popOverView.removeFromSuperview()
                    self.populateVersionLabel()
                })
            }
        }
    }
}
