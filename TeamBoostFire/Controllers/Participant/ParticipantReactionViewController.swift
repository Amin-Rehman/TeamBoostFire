//
//  ParticipantReactionViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 18.08.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit
import Lottie

class ParticipantReactionViewController: UIViewController {
    @IBOutlet weak var swipeRightAnimationView: AnimationView!
    @IBOutlet weak var swipeLeftAnimationView: AnimationView!
    @IBOutlet weak var swipeUpAnimationView: AnimationView!
    @IBOutlet weak var swipeDownAnimationView: AnimationView!
    @IBOutlet weak var doubleTapAnimationView: AnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setLoopMode()
    }

    override func viewDidAppear(_ animated: Bool) {
        playAllAnimations()
    }

    private func setLoopMode() {
        swipeRightAnimationView.loopMode = .loop
        swipeLeftAnimationView.loopMode = .loop
        swipeUpAnimationView.loopMode = .loop
        swipeDownAnimationView.loopMode = .loop
        doubleTapAnimationView.loopMode = .loop
    }

    private func playAllAnimations() {
        swipeRightAnimationView.play()
        swipeLeftAnimationView.play()
        swipeUpAnimationView.play()
        swipeDownAnimationView.play()
        doubleTapAnimationView.play()
    }
}
