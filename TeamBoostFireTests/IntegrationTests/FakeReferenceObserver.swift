//
//  FakeReferenceObserver.swift
//  TeamBoostFireTests
//
//  Created by Amin Rehman on 15.11.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation
import TeamBoostFire


class FakeReferenceObserver: ReferenceObserving {
    // MARK: -
    public var participantListChangedSubscriber:(([Participant]) -> Void)?

    // MARK: -

    func observeSpeakerOrderDidChange(subscriber: @escaping ([String]) -> Void) {
    }

    func observeParticipantListChanges(subscriber: @escaping ([Participant]) -> Void) {
        participantListChangedSubscriber = subscriber
    }

    func observeIAmDoneInterrupt(subscriber: @escaping () -> Void) {
    }

    func observeMeetingStateDidChange(subscriber: @escaping (MeetingState) -> Void) {
    }

    func observeMeetingParamsDidChange(subscriber: @escaping (MeetingsParams) -> Void) {
    }

}
