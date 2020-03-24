//
//  FakeReferenceObserver.swift
//  TeamBoostFireTests
//
//  Created by Amin Rehman on 15.11.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation
import TeamBoostFire
import TeamBoostKit


class FakeReferenceObserver: ReferenceObserving {

    // MARK: -
    public var participantListChangedSubscriber:(([Participant]) -> Void)?
    public var iAmDoneInterruptSubscriber:((TimeInterval) -> Void)?
    public var callToSpeakerDidChange:((String) -> Void)?

    // MARK: -

    func observeSpeakerOrderDidChange(subscriber: @escaping ([String]) -> Void) {
    }

    func observeModeratorHasControlDidChange(subscriber: @escaping (Bool) -> Void) {
    }

    func observeParticipantListChanges(subscriber: @escaping ([Participant]) -> Void) {
        participantListChangedSubscriber = subscriber
    }

    func observeIAmDoneInterrupt(subscriber: @escaping (TimeInterval) -> Void) {
        iAmDoneInterruptSubscriber = subscriber
    }

    func observeMeetingStateDidChange(subscriber: @escaping (MeetingState) -> Void) {
    }

    func observeMeetingParamsDidChange(subscriber: @escaping (MeetingsParams) -> Void) {
    }

    func observeCallToSpeakerDidChange(subscriber: @escaping (String) -> Void) {
        callToSpeakerDidChange = subscriber
    }
}
