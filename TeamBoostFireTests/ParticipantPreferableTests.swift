//
//  ParticipantPreferableTests.swift
//  TeamBoostFireTests
//
//  Created by Amin Rehman on 13.09.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import XCTest
@testable import TeamBoostFire

class ParticipantPreferableTests: XCTestCase {

    func testPreferParticipant() throws {
        let speakingRecord1 = SpeakerRecord(participantId: "id1", speakingTime: 31)
        let speakingRecord2 = SpeakerRecord(participantId: "id2", speakingTime: 20)
        let speakingRecord3 = SpeakerRecord(participantId: "id3", speakingTime: 21)
        let speakingRecord4 = SpeakerRecord(participantId: "id4", speakingTime: 22)
        let speakingRecord5 = SpeakerRecord(participantId: "id5", speakingTime: 23)
        let speakingRecord6 = SpeakerRecord(participantId: "id6", speakingTime: 24)

        let originalSpeakingRecords = [speakingRecord1, speakingRecord2, speakingRecord3,
                                       speakingRecord4, speakingRecord5, speakingRecord6]

        let adjustedRecords = try ParticipantPreferable.prefer(participantIdOfInterest: "id4",
                                                           originalSpeakingRecord: originalSpeakingRecords)
        XCTAssertEqual(adjustedRecords[0], speakingRecord4)
        XCTAssertEqual(adjustedRecords[1], speakingRecord1)
        XCTAssertEqual(adjustedRecords[2], speakingRecord2)
        XCTAssertEqual(adjustedRecords[3], speakingRecord3)
        XCTAssertEqual(adjustedRecords[4], speakingRecord5)
        XCTAssertEqual(adjustedRecords[5], speakingRecord6)
        XCTAssertEqual(adjustedRecords.count, 6)
    }

    func testPreferredParticipantNotPresentRetainsOrder() throws {
        let speakingRecord1 = SpeakerRecord(participantId: "id1", speakingTime: 31)
        let speakingRecord2 = SpeakerRecord(participantId: "id2", speakingTime: 20)
        let speakingRecord3 = SpeakerRecord(participantId: "id3", speakingTime: 21)
        let speakingRecord4 = SpeakerRecord(participantId: "id4", speakingTime: 22)
        let speakingRecord5 = SpeakerRecord(participantId: "id5", speakingTime: 23)
        let speakingRecord6 = SpeakerRecord(participantId: "id6", speakingTime: 24)

        let originalSpeakingRecords = [speakingRecord1, speakingRecord2, speakingRecord3,
                                       speakingRecord3, speakingRecord4, speakingRecord5, speakingRecord6]

        let adjustedRecords = try ParticipantPreferable.prefer(participantIdOfInterest: "idxx",
                                                           originalSpeakingRecord: originalSpeakingRecords)
        XCTAssertEqual(originalSpeakingRecords, adjustedRecords)
    }

}
