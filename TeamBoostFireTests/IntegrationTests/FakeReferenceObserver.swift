//
//  FakeReferenceObserver.swift
//  TeamBoostFireTests
//
//  Created by Amin Rehman on 15.11.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation
import TeamBoostFire

struct FakeReferenceObserver: ReferenceObserving {
    func observeSpeakerOrderDidChange() {
    }

    func observeParticipantListChanges() {
    }

    func observeIAmDoneInterrupt() {
    }

    func observeCurrentSpeakerMaximumSpeakingTimeChanged() {
    }

    func observeMeetingStateDidChange() {
    }

    func observeMeetingParamsDidChange() {
    }

    mutating func setObserver(teamBoostCore: TeamBoostCore) {
    }
}
