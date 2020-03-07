//
//  HostPersistenceTests.swift
//  TeamBoostFireTests
//
//  Created by Amin Rehman on 04.03.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import XCTest
@testable import TeamBoostFire

class HostPersistenceTests: XCTestCase {
    var sut: HostPersistenceStorage!

    override func setUp() {
        let managedObjectContext = ManagedObjectContextFactory.make()
        sut = HostPersistenceStorage(managedObjectContext: managedObjectContext)
    }

    override func tearDown() {
        sut = nil
    }

    func testSaveAndRetrieveMeetingIdentifierLocalChange() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let result = sut.fetchAll().first
        XCTAssertEqual(result?.meetingIdentifier, stubMeetingIdentifier)
        let meetingIdentifierTimestamp = result!.meetingIdentifierChanged!.doubleValue
        XCTAssertGreaterThan(meetingIdentifierTimestamp, 0.0)
    }

    func testSaveAndRetrieveMeetingParamsMeetingTimeLocalChange() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)

        sut.setMeetingParamsMeetingTime(meetingTime: 100,
                                        meetingIdentifier: stubMeetingIdentifier,
                                        localChange: true)

        let meetingTimeValuePair = sut.meetingParamsMeetingTime(for: stubMeetingIdentifier)
        XCTAssertEqual(meetingTimeValuePair.value, 100)
        XCTAssertGreaterThan(meetingTimeValuePair.timestamp.doubleValue, 0.0)
    }

    func testSaveAndRetrieveMeetingParamsMeetingTime() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)

        sut.setMeetingParamsMeetingTime(meetingTime: 100,
                                        meetingIdentifier: stubMeetingIdentifier,
                                        localChange: false)

        let meetingTimeValuePair = sut.meetingParamsMeetingTime(for: stubMeetingIdentifier)
        XCTAssertEqual(meetingTimeValuePair.value, 100)
        XCTAssertEqual(meetingTimeValuePair.timestamp.doubleValue, 0)
    }
}
