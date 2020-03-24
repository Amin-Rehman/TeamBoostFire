//
//  ReferenceHolding.swift
//  TeamBoostKit
//
//  Created by Amin Rehman on 24.03.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import Foundation

public protocol ReferenceHolding {
    func setupDefaultValues(with params: MeetingsParams)
    func setReferenceForMeetingStarted()
    func setReferenceForMeetingEnded()
    func setReferenceForSpeakerOrder(speakingOrder: [String])
    func setReferenceForModeratorHasControl(controlState: Bool)
    func setParticipantReference(participantName: String,
                                 participantId: String)
    func setIAmDoneInterruptReference(timeInterval: TimeInterval)
    func setCallToSpeakerReference(callToSpeakerReferenceValue: String)

    // TODO: Just test mode - to be removed
    func testModeSetReferenceForNoParticipants()
    func testModeSetReferenceForFakeParticipants()
}
