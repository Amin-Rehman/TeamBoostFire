//
//  PartcipantSelfSpeakerViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 02.05.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class ParticipantSelfSpeakerViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    private var secondTickTimer: Timer?
    private var secondTimerCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        secondTimerCount = 0
        updateSpeakingTimerLabel()
        startSecondTickerTimer()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        secondTimerCount = 0
        stopSecondTickerTimer()
    }

    private func startSecondTickerTimer() {
        secondTickTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                               selector: #selector(secondTicked),
                                               userInfo: nil, repeats: true)
    }

    private func stopSecondTickerTimer() {
        secondTickTimer?.invalidate()
        secondTickTimer = nil
    }

    @IBAction func doneTapped(_ sender: Any) {
        CoreServices.shared.registerParticipantIsDoneInterrupt()
        dismiss(animated: true, completion: nil)
    }


    @objc func secondTicked() {
        secondTimerCount = secondTimerCount + 1
        updateSpeakingTimerLabel()
    }

    private func updateSpeakingTimerLabel() {
        let timeElapsedString = secondTimerCount.minutesAndSecondsPrettyString()
        timerLabel.text = timeElapsedString
    }
}
