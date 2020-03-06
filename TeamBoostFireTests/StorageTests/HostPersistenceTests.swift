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

    func testSaveAndRetrieveMeetingIdentifierToPersistence() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        sut.insertNewEntity(with: "foo")
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)
    }

    func testSaveAndRetrieveMeetingParamsMeetingTimeLocalChange() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.insertNewEntity(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)

        sut.setMeetingParamsMeetingTime(meetingTime: 100,
                                        meetingIdentifier: stubMeetingIdentifier,
                                        localChange: true)

        let meetingTimeFromPersistence = sut.meetingParamsMeetingTime(for: stubMeetingIdentifier)
        XCTAssertEqual(meetingTimeFromPersistence, 100)
    }
}
