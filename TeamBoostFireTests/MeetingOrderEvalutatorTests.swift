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
                                                   "Prof": 5]
        //MeetingOrder
        let result = MeetingOrderEvaluator.evaluateOrder(
            participantTotalSpeakingRecord: totalSpeakingTimeParticipantRecords, maxTalkingTime: 15)

        XCTAssertEqual(result?.count, 3)
        XCTAssertEqual(result?[0].participantId, "Prof")
        XCTAssertEqual(result?[0].speakingTime, 23)

        XCTAssertEqual(result?[1].participantId, "amin")
        XCTAssertEqual(result?[1].speakingTime, 15)

        XCTAssertEqual(result?[2].participantId, "patrick")
        XCTAssertEqual(result?[2].speakingTime, 15)


    }

}
