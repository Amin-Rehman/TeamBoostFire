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
    @IBOutlet weak var rightArrowButton: UIButton!
    @IBOutlet weak var downArrowButton: UIButton!
    @IBOutlet weak var upArrowButton: UIButton!
    @IBOutlet weak var leftArrowButton: UIButton!

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
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.autoreverse], animations: {
                self.rightArrowButton.transform = CGAffineTransform(scaleX: 1.10, y: 1.10)
            }, completion: {_ in
                self.rightArrowButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        } else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.autoreverse], animations: {
                self.leftArrowButton.transform = CGAffineTransform(scaleX: 1.10, y: 1.10)
            }, completion: {_ in
                self.leftArrowButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        } else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.autoreverse], animations: {
                self.upArrowButton.transform = CGAffineTransform(scaleX: 1.10, y: 1.10)
            }, completion: {_ in
                self.upArrowButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.autoreverse], animations: {
                self.downArrowButton.transform = CGAffineTransform(scaleX: 1.10, y: 1.10)
            }, completion: {_ in
                self.downArrowButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        }
    }
}
