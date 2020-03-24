//
//  FakeReferenceHolding.swift
//  TeamBoostFireTests
//
//  Created by Amin Rehman on 15.11.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation
import TeamBoostFire
import TeamBoostKit

struct FakeReferenceHolding: ReferenceHolding {
    func setupDefaultValues(with params: MeetingsParams) {
    }

    func setParticipantReference(participantName: String, participantId: String) {
    }

    func setIAmDoneInterruptReference(timeInterval: TimeInterval) {
    }

    func setCallToSpeakerReference(callToSpeakerReferenceValue: String) {
    }

    func setReferenceForMeetingStarted() {
    }

    func setReferenceForMeetingEnded() {
    }

    func setReferenceForSpeakerOrder(speakingOrder: [String]) {
    }

    func setReferenceForModeratorHasControl(controlState: Bool) {
    }

    func testModeSetReferenceForNoParticipants() {
    }

    func testModeSetReferenceForFakeParticipants() {
    }
}
