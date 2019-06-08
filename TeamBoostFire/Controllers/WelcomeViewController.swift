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
                })
            }
        }
    }
}
