//
//  ParticipantGameControllerViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 04.08.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class ParticipantGameControllerViewController: UIViewController {

    @IBOutlet weak var agreeLabel: UILabel!
    @IBOutlet weak var disagreeLabel: UILabel!

    override func viewDidLoad() {
        agreeLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        disagreeLabel.transform = CGAffineTransform(rotationAngle: (-1) * CGFloat.pi / 2)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)

        super.viewDidLoad()
    }

    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            print("Swipe Right")
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            print("Swipe Left")
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
            print("Swipe Up")
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            print("Swipe Down")
        }
    }
}
