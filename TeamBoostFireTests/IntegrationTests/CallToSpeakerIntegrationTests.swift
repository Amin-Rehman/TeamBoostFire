//
//  CallToSpeakerIntegrationTests.swift
//  TeamBoostFireTests
//
//  Created by Amin Rehman on 25.11.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import XCTest
@testable import TeamBoostFire
@testable import TeamBoostKit

class CallToSpeakerIntegrationTests: XCTestCase {
    var teamBoostKitDomain: TeamBoostKitDomain!
    var fakeReferenceObserver: FakeReferenceObserver!

    override func setUp() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()

        let totalMeetingTime = 40
        let maxAllowedTalkTime = 10
        let meetingParams = MeetingsParams(agenda: "Foo Agenda",
                                           meetingTime: totalMeetingTime,
                                           maxTalkTime: maxAllowedTalkTime,
                                           moderationMode: .AutoModerated)

        fakeReferenceObserver = FakeReferenceObserver()
        teamBoostKitDomain = TeamBoostKitDomain.make(referenceObserver: fakeReferenceObserver,
                                          referenceHolder: FakeReferenceHolding(),
                                          meetingIdentifier: "meetingId",
                                          meetingParams: meetingParams)
    }

    override func tearDown() {
        fakeReferenceObserver = nil
        teamBoostKitDomain = nil
    }

    // Starting a meeting and participant 3 just calls call to speaker
    // Verify that the storage gets updated
    func testCallingToSpeakerUpdatesStorage() {
        // Setup the meeting on the host side

        let fakeSpeakerOrderObserver = FakeSpeakerOrderObserver()


        XCTAssertEqual(teamBoostKitDomain.meetingIdentifier, "meetingId")
        let participant1 = Participant(id: "id1", name: "participant1", speakerOrder: -1)
        let participant2 = Participant(id: "id2", name: "participant2", speakerOrder: -1)
        let participant3 = Participant(id: "id3", name: "participant3", speakerOrder: -1)

        let allParticipants = [participant1, participant2, participant3]
        // Fake call this block
        // In the real world , the firebase callback will call this block
        fakeReferenceObserver.participantListChangedSubscriber!(allParticipants)
        XCTAssertEqual(teamBoostKitDomain.allParticipants, allParticipants)

        let speakingOrderPredicate = NSPredicate { (item, bindings) -> Bool in
            let domain = item as! TeamBoostKitDomain
            return domain.speakerOrder.count == 3 &&
                domain.speakerOrder[0] == "id1"
        }

        let expectation = self.expectation(for: speakingOrderPredicate,
                                           evaluatedWith: teamBoostKitDomain,
                                           handler: nil)

        teamBoostKitDomain.startMeeting()
        // Initialising it simply starts the timers
        let hostMeetingControllerService = HostMeetingControllerService(meetingParams: teamBoostKitDomain.meetingParams,
                                                                        orderObserver: fakeSpeakerOrderObserver,
                                                                        meetingMode: .AutoModerated,
                                                                        domain: teamBoostKitDomain)

        // Verify that the participants are added to the meeting
        self.wait(for: [expectation], timeout: 2.0)

        // Speaker continues talking and then we verify the storage
        fakeReferenceObserver.callToSpeakerDidChange!("id3_uuid1")

        // Wait for notification to get fired
        let notificationName = Notification.Name(TeamBoostNotifications.callToSpeakerDidChange.rawValue)
        let notificationExpectation =
            self.expectation(forNotification: notificationName,
                             object: nil, handler: nil)

        self.wait(for: [notificationExpectation], timeout: 1.0)
        XCTAssertEqual(hostMeetingControllerService.storage.callToSpeakerQueue, ["id3"])
    }

    // Starting a meeting and participant 3 just calls call to speaker
    // Verify that the speaking order
    func testCallingToSpeakerUpdatesSpeakingOrder() {
        let totalMeetingTime = 60
        let maxAllowedTalkTime = 10
        // Setup the meeting on the host side
        let meetingParams = MeetingsParams(agenda: "Foo Agenda",
                                           meetingTime: totalMeetingTime,
                                           maxTalkTime: maxAllowedTalkTime,
                                           moderationMode: .AutoModerated)

        let fakeSpeakerOrderObserver = FakeSpeakerOrderObserver()

        XCTAssertEqual(teamBoostKitDomain.meetingIdentifier, "meetingId")
        let participant1 = Participant(id: "id1", name: "participant1", speakerOrder: -1)
        let participant2 = Participant(id: "id2", name: "participant2", speakerOrder: -1)
        let participant3 = Participant(id: "id3", name: "participant3", speakerOrder: -1)

        let allParticipants = [participant1, participant2, participant3]
        // Fake call this block
        // In the real world , the firebase callback will call this block
        fakeReferenceObserver.participantListChangedSubscriber!(allParticipants)
        XCTAssertEqual(teamBoostKitDomain.allParticipants, allParticipants)

        let speakingOrderPredicate = NSPredicate { (item, bindings) -> Bool in
            let domain = item as! TeamBoostKitDomain
            return domain.speakerOrder.count == 3 &&
                domain.speakerOrder[0] == "id1"
        }

        let expectation = self.expectation(for: speakingOrderPredicate,
                                           evaluatedWith: teamBoostKitDomain,
                                           handler: nil)

        teamBoostKitDomain.startMeeting()
        // Initialising it simply starts the timers
        let hostMeetingControllerService = HostMeetingControllerService(meetingParams: meetingParams,
                                                                        orderObserver: fakeSpeakerOrderObserver,
                                                                        meetingMode: .AutoModerated,
                                                                        domain: teamBoostKitDomain)
        hostMeetingControllerService.startParticipantSpeakingSessions()

        // Verify that the participants are added to the meeting
        self.wait(for: [expectation], timeout: 2.0)

        //1: After 10 seconds the speaker should switch
        let firstSpeakerSwitchPredicate = NSPredicate { (item, bindings) -> Bool in
            let domain = item as! TeamBoostKitDomain
            return domain.speakerOrder[0] == "id2"
        }

        let firstSpeakerSwitchExpectation = self.expectation(for: firstSpeakerSwitchPredicate,
                                                             evaluatedWith: teamBoostKitDomain,
                                                             handler: nil)

        // Give one second of extra cushion
        self.wait(for: [firstSpeakerSwitchExpectation], timeout: 11.0)

        //2: After 4 seconds, seconds speaker says that she is done!
        let secondSpeakerSwitchPredicate = NSPredicate { (item, bindings) -> Bool in
            let domain = item as! TeamBoostKitDomain
            return domain.speakerOrder[0] != "id2"
        }

        let secondSpeakerSwitchExpectation = self.expectation(for: secondSpeakerSwitchPredicate,
                                                              evaluatedWith: teamBoostKitDomain,
                                                              handler: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.00, qos: .userInteractive) {
            self.fakeReferenceObserver.iAmDoneInterruptSubscriber!(6.00)
        }

        // Speaker 1 invokes call to speaker
        fakeReferenceObserver.callToSpeakerDidChange!("id1_uuid1")

        self.wait(for: [secondSpeakerSwitchExpectation], timeout: 5.5)

        // Verify speaking order
        let speakingOrder = teamBoostKitDomain.speakerOrder
        XCTAssertEqual(speakingOrder[0], "id1")
        XCTAssertEqual(speakingOrder[1], "id3")
        XCTAssertEqual(speakingOrder[2], "id2")
    }
}
