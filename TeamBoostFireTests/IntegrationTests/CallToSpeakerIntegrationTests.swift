//
//  CallToSpeakerIntegrationTests.swift
//  TeamBoostFireTests
//
//  Created by Amin Rehman on 25.11.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import XCTest
@testable import TeamBoostFire

class CallToSpeakerIntegrationTests: XCTestCase {
    override func setUp() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }

    override func tearDown() {
    }

    // Starting a meeting and participant 3 just calls call to speaker
    // Verify that the storage gets updated
    func testCallingToSpeakerUpdatesStorage() {
        let totalMeetingTime = 40
        let maxAllowedTalkTime = 10
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
}
