//
//  MeetingControllerSettingTicker.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 27.08.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation


class MeetingControllerSecondTicker {
    weak public var secondTickObserver: SpeakerControllerSecondTickObserver?
    var storage: MeetingControllerStorage
    private var secondTickTimer: Timer?

    init(with storage: MeetingControllerStorage) {
        self.storage = storage
        // First second seems to get missed, so brute force it
        secondTicked()
    }

    @objc private func secondTicked() {
        guard let speakerOrder = HostCoreServices.shared.speakerOrder,
            let currentSpeakerIdentifier = speakerOrder.first else {
                assertionFailure("Unable to retrieve current speaker")
                return
        }

        guard var speakerTime = storage.participantTotalSpeakingRecord[currentSpeakerIdentifier] else {
            assertionFailure("Unable to retrieve speaker time")
            return
        }

        speakerTime = speakerTime + 1
        storage.updateTotalSpeakingTime(for: currentSpeakerIdentifier, newTime: speakerTime)
        secondTickObserver?.speakerSecondTicked(participantIdentifier: currentSpeakerIdentifier)
    }

    public func startSecondTickerTimer() {
        secondTickTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                               selector: #selector(secondTicked),
                                               userInfo: nil, repeats: true)
    }

    public func stopSecondTickerTimer() {
        secondTickTimer?.invalidate()
        secondTickTimer = nil
    }

}
