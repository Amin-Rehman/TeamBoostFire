//
//  MeetingOrderEvalutatorTests.swift
//  TeamBoostFireTests
//
//  Created by Amin Rehman on 17.06.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import XCTest
@testable import TeamBoostFire

class MeetingOrderEvalutatorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLeastSpeakerGetsPreferenceInMeetingOf3() {
        let totalSpeakingTimeParticipantRecords = ["amin": 10,
                                                   "patrick": 15,
                                                   "prof": 5]
        //MeetingOrder
        let result = MeetingOrderEvaluator.evaluateOrder(
            participantTotalSpeakingRecord: totalSpeakingTimeParticipantRecords, maxTalkingTime: 15)

        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].participantId, "prof")
        XCTAssertEqual(result[0].speakingTime, 23)

        XCTAssertEqual(result[1].participantId, "amin")
        XCTAssertEqual(result[1].speakingTime, 15)

        XCTAssertEqual(result[2].participantId, "patrick")
        XCTAssertEqual(result[2].speakingTime, 15)

    }

    func testLeastSpeakerGetsPreferenceInMeetingOf5() {
        let totalSpeakingTimeParticipantRecords = ["amin": 10,
                                                   "patrick": 15,
                                                   "prof": 5,
                                                   "ned": 14,
                                                   "jon": 8]
        //MeetingOrder
        let result = MeetingOrderEvaluator.evaluateOrder(
            participantTotalSpeakingRecord: totalSpeakingTimeParticipantRecords, maxTalkingTime: 15)

        XCTAssertEqual(result.count, 5)
        XCTAssertEqual(result[0].participantId, "prof")
        XCTAssertEqual(result[0].speakingTime, 23)

        XCTAssertEqual(result[1].participantId, "jon")
        XCTAssertEqual(result[1].speakingTime, 21)

        XCTAssertEqual(result[2].participantId, "amin")
        XCTAssertEqual(result[2].speakingTime, 18)

        XCTAssertEqual(result[3].participantId, "ned")
        XCTAssertEqual(result[3].speakingTime, 15)

        XCTAssertEqual(result[4].participantId, "patrick")
        XCTAssertEqual(result[4].speakingTime, 15)

    }


    // MARK: - Call to speaker tests
    func testCallToSpeakerAdjustment() {
        var originalSpeakingRecord = [SpeakerRecord]()
        originalSpeakingRecord.append(SpeakerRecord(participantId: "id1", speakingTime: 12))
        originalSpeakingRecord.append(SpeakerRecord(participantId: "id2", speakingTime: 4))
        originalSpeakingRecord.append(SpeakerRecord(participantId: "id3", speakingTime: 12))
        originalSpeakingRecord.append(SpeakerRecord(participantId: "id4", speakingTime: 10))
        originalSpeakingRecord.append(SpeakerRecord(participantId: "id5", speakingTime: 5))
        originalSpeakingRecord.append(SpeakerRecord(participantId: "id6", speakingTime: 7))

        let adjustedSpeakingRecord = MeetingOrderEvaluator.makeSpeakerRecord(
            originalSpeakerRecord: originalSpeakingRecord,
            callToSpeakerQueue: ["id3", "id4"])

        XCTAssertEqual(adjustedSpeakingRecord[0].participantId, "id3")
        XCTAssertEqual(adjustedSpeakingRecord[0].speakingTime, 12)

        XCTAssertEqual(adjustedSpeakingRecord[1].participantId, "id4")
        XCTAssertEqual(adjustedSpeakingRecord[1].speakingTime, 10)

        XCTAssertEqual(adjustedSpeakingRecord[2].participantId, "id1")
        XCTAssertEqual(adjustedSpeakingRecord[2].speakingTime, 12)

        XCTAssertEqual(adjustedSpeakingRecord[3].participantId, "id2")
        XCTAssertEqual(adjustedSpeakingRecord[3].speakingTime, 4)

        XCTAssertEqual(adjustedSpeakingRecord[4].participantId, "id5")
        XCTAssertEqual(adjustedSpeakingRecord[4].speakingTime, 5)

        XCTAssertEqual(adjustedSpeakingRecord[5].participantId, "id6")
        XCTAssertEqual(adjustedSpeakingRecord[5].speakingTime, 7)
    }
}
