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

    private weak var participantControllerService: ParticipantControllerService?

    init(nibName: String,
         participantControllerService: ParticipantControllerService) {
        self.participantControllerService = participantControllerService
        super.init(nibName: nibName, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        participantControllerService?.participantTimeUpdateable = self
        updateSpeakingTimerLabel()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }


    @IBAction func doneTapped(_ sender: Any) {
        ParticipantCoreServices.shared.registerParticipantIsDoneInterrupt()
        dismiss(animated: true, completion: nil)
    }

    private func updateSpeakingTimerLabel() {
        let timeElapsedString = 0.minutesAndSecondsPrettyString()
        timerLabel.text = timeElapsedString
    }
}

extension ParticipantSelfSpeakerViewController: ParticipantTimeUpdatable {
    func updateTime(participantLeftSpeakingTime: Int, meetingLeftTime: Int) {
        timerLabel.text = participantLeftSpeakingTime.minutesAndSecondsPrettyString()
    }

    func updateSpeakingOrder(speakingOrder: [String]) {
        // Not implemented
    }

}
