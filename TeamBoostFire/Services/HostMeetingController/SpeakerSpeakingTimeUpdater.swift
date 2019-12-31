//
//  MeetingControllerSettingTicker.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 27.08.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

/**
 Responsible for updating the speaking time of each speaker every second
 */

class SpeakerSpeakingTimeUpdater {
    weak public var secondTickObserver: SpeakerControllerSecondTickObserver?
    var storage: MeetingControllerStorage
    private var secondTickTimer: Timer?
    private let coreServices: HostCoreServices

    init(with storage: MeetingControllerStorage,
         coreServices: HostCoreServices) {
        // First second seems to get missed, so brute force it
        self.storage = storage
        self.coreServices = coreServices
        secondTicked()
    }

    @objc private func secondTicked() {
        print("ALOG: MeetingControllerSecondTicker: secondTicked")
        guard let speakerOrder = coreServices.speakerOrder,
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

    public func start() {
        print("ALOG: MeetingControllerSecondTicker: start")
        secondTickTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                               selector: #selector(secondTicked),
                                               userInfo: nil, repeats: true)
    }

    public func stop() {
        print("ALOG: MeetingControllerSecondTicker: stop")
        secondTickTimer?.invalidate()
        secondTickTimer = nil
    }

}
