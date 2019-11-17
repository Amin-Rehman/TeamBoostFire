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
    func observeSpeakerOrderDidChange(subscriber: @escaping ([String]) -> Void) {
    }

    func observeParticipantListChanges(subscriber: @escaping ([Participant]) -> Void) {
    }

    func observeIAmDoneInterrupt(subscriber: @escaping () -> Void) {
    }

    func observeMeetingStateDidChange(subscriber: @escaping (MeetingState) -> Void) {
    }

    func observeMeetingParamsDidChange(subscriber: @escaping (MeetingsParams) -> Void) {
    }

}
