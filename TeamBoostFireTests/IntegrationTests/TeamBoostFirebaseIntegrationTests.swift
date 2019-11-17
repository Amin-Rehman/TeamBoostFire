//
//  TeamBoostFirebaseIntegrationTests.swift
//  TeamBoostFireTests
//
//  Created by Amin Rehman on 13.11.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import XCTest
@testable import TeamBoostFire

class TeamBoostFirebaseIntegrationTests: XCTestCase {

    override func setUp() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMeetingGetsSetupOnTheHostSideWithCorrectNumberOfParticipants() {
        // Setup the meeting on the host side
        let hostCoreServices = HostCoreServices.shared
        let meetingParams = MeetingsParams(agenda: "Foo Agenda",
                                           meetingTime: 4,
                                           maxTalkTime: 10,
                                           moderationMode: .AutoModerated)

        hostCoreServices.setupCore(with: meetingParams,
                                   referenceHolder: FakeReferenceHolding(),
                                   referenceObserver: FakeReferenceObserver(),
                                   meetingIdentifier: "meetingId")
        // Make (3) Participants join the meeting

//        // Setup Participant 1
//        let participant1 = Participant(id: "partipant1Id",
//                                       name: "partipant1Name",
//                                       speakerOrder: -1)
//        let participantCoreServices1 = ParticipantCoreServices.shared
//        participantCoreServices1.setupCore(with: participant1,
//                                           meetingCode: meetingIdentifier)
//
//        // Setup Participant 2
//        let participant2 = Participant(id: "partipant2Id",
//                                       name: "partipant2Name",
//                                       speakerOrder: -1)
//
//        let participantCoreServices2 = ParticipantCoreServices.shared
//        participantCoreServices2.setupCore(with: participant2,
//                                           meetingCode: meetingIdentifier)
//
//        // Setup Participant 3
//        let participant3 = Participant(id: "partipant3Id",
//                                       name: "partipant3Name",
//                                       speakerOrder: -1)
//
//        let participantCoreServices3 = ParticipantCoreServices.shared
//        participantCoreServices3.setupCore(with: participant3,
//                                           meetingCode: meetingIdentifier)
//
//
//        hostCoreServices.startMeeting()
    }

}
