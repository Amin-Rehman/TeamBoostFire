//
//  TeamBoostFirebaseIntegrationTests.swift
//  TeamBoostFireTests
//
//  Created by Amin Rehman on 13.11.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import XCTest
@testable import TeamBoostFire

class FakeSpeakerOrderObserver: SpeakerControllerOrderObserver
{
    var speakingRecord: [ParticipantId: SpeakingTime]?
    func speakingOrderUpdated(totalSpeakingRecord: [ParticipantId: SpeakingTime]) {
        self.speakingRecord = totalSpeakingRecord
    }
}

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

        let fakeReferenceObserver = FakeReferenceObserver()

        hostCoreServices.setupCore(with: meetingParams,
                                   referenceHolder: FakeReferenceHolding(),
                                   referenceObserver: fakeReferenceObserver,
                                   meetingIdentifier: "meetingId")

        XCTAssertEqual(hostCoreServices.meetingIdentifier, "meetingId")
        let participant1 = Participant(id: "id1", name: "participant1", speakerOrder: -1)
        let participant2 = Participant(id: "id2", name: "participant2", speakerOrder: -1)
        let participant3 = Participant(id: "id3", name: "participant3", speakerOrder: -1)

        let allParticipants = [participant1, participant2, participant3]
        // Fake call this block
        // In the real world , the firebase callback will call this block
        fakeReferenceObserver.participantListChangedSubscriber!(allParticipants)
        XCTAssertEqual(hostCoreServices.allParticipants, allParticipants)

    }

    func testSimpleMeetingWithOneRound() {
        let totalMeetingTime = 12
        let maxAllowedTalkTime = 4
        // Setup the meeting on the host side
        let meetingParams = MeetingsParams(agenda: "Foo Agenda",
                                           meetingTime: totalMeetingTime,
                                           maxTalkTime: maxAllowedTalkTime,
                                           moderationMode: .AutoModerated)

        let fakeReferenceObserver = FakeReferenceObserver()
        let fakeSpeakerOrderObserver = FakeSpeakerOrderObserver()

        let hostCoreServices = HostCoreServices.shared
        hostCoreServices.setupCore(with: meetingParams,
                                   referenceHolder: FakeReferenceHolding(),
                                   referenceObserver: fakeReferenceObserver,
                                   meetingIdentifier: "meetingId")

        XCTAssertEqual(hostCoreServices.meetingIdentifier, "meetingId")
        let participant1 = Participant(id: "id1", name: "participant1", speakerOrder: -1)
        let participant2 = Participant(id: "id2", name: "participant2", speakerOrder: -1)
        let participant3 = Participant(id: "id3", name: "participant3", speakerOrder: -1)

        let allParticipants = [participant1, participant2, participant3]
        // Fake call this block
        // In the real world , the firebase callback will call this block
        fakeReferenceObserver.participantListChangedSubscriber!(allParticipants)
        XCTAssertEqual(hostCoreServices.allParticipants, allParticipants)

        let speakingOrderPredicate = NSPredicate { (item, bindings) -> Bool in
            let coreService = item as! HostCoreServices
            return coreService.speakerOrder!.count == 3 &&
                coreService.speakerOrder?[0] == "id1"
        }

        let expectation = self.expectation(for: speakingOrderPredicate,
                                           evaluatedWith: hostCoreServices,
                                           handler: nil)

        hostCoreServices.startMeeting()
        // Initialising it simply starts the timers
        let hostMeetingControllerService = HostMeetingControllerService(meetingParams: meetingParams,
                                         orderObserver: fakeSpeakerOrderObserver,
                                         meetingMode: .AutoModerated,
                                     coreServices: hostCoreServices)

        // Verify that the participants are added to the meeting
        self.wait(for: [expectation], timeout: 2.0)

        // After 4 seconds the speaker should switch
        let firstSpeakerSwitchPredicate = NSPredicate { (item, bindings) -> Bool in
            let coreService = item as! HostCoreServices
            return coreService.speakerOrder?[0] == "id2"
        }

        let firstSpeakerSwitchExpectation = self.expectation(for: firstSpeakerSwitchPredicate,
                                           evaluatedWith: hostCoreServices,
                                           handler: nil)

        self.wait(for: [firstSpeakerSwitchExpectation], timeout: 5.0)

        // Then the speaker should change again
        let secondSpeakerSwitchPredicate = NSPredicate { (item, bindings) -> Bool in
            let coreService = item as! HostCoreServices
            return coreService.speakerOrder?[0] == "id3"
        }

        let secondSpeakerSwitchExpectation = self.expectation(for: secondSpeakerSwitchPredicate,
                                           evaluatedWith: hostCoreServices,
                                           handler: nil)

        self.wait(for: [secondSpeakerSwitchExpectation], timeout: 5.0)

        // To silence the warning
        _ = hostMeetingControllerService
    }

}
