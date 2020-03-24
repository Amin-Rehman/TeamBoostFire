//
//  TeamBoostFirebaseIntegrationTests.swift
//  TeamBoostFireTests
//
//  Created by Amin Rehman on 13.11.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import XCTest
@testable import TeamBoostFire
@testable import TeamBoostKit

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
    }

    func testMeetingGetsSetupOnTheHostSideWithCorrectNumberOfParticipants() {
        let totalMeetingTime = 12
        let maxAllowedTalkTime = 4
        let meetingParams = MeetingsParams(agenda: "Foo Agenda",
                                           meetingTime: totalMeetingTime,
                                           maxTalkTime: maxAllowedTalkTime,
                                           moderationMode: .AutoModerated)

        let fakeReferenceObserver = FakeReferenceObserver()
        let hostDomain = TeamBoostKitDomain.make(referenceObserver: fakeReferenceObserver,
                                         referenceHolder: FakeReferenceHolding(),
                                         meetingIdentifier: "meetingId",
                                         meetingParams: meetingParams)

        XCTAssertEqual(hostDomain.meetingIdentifier, "meetingId")
        let participant1 = Participant(id: "id1", name: "participant1", speakerOrder: -1)
        let participant2 = Participant(id: "id2", name: "participant2", speakerOrder: -1)
        let participant3 = Participant(id: "id3", name: "participant3", speakerOrder: -1)

        let allParticipants = [participant1, participant2, participant3]
        // Fake call this block
        // In the real world , the firebase callback will call this block
        fakeReferenceObserver.participantListChangedSubscriber!(allParticipants)
        XCTAssertEqual(hostDomain.allParticipants, allParticipants)

    }

    func testSimpleMeetingWithOneRound() {
        let fakeSpeakerOrderObserver = FakeSpeakerOrderObserver()

        let totalMeetingTime = 12
        let maxAllowedTalkTime = 4
        let meetingParams = MeetingsParams(agenda: "Foo Agenda",
                                           meetingTime: totalMeetingTime,
                                           maxTalkTime: maxAllowedTalkTime,
                                           moderationMode: .AutoModerated)

        let fakeReferenceObserver = FakeReferenceObserver()
        let hostDomain = TeamBoostKitDomain.make(referenceObserver: fakeReferenceObserver,
                                         referenceHolder: FakeReferenceHolding(),
                                         meetingIdentifier: "meetingId",
                                         meetingParams: meetingParams)


        XCTAssertEqual(hostDomain.meetingIdentifier, "meetingId")
        let participant1 = Participant(id: "id1", name: "participant1", speakerOrder: -1)
        let participant2 = Participant(id: "id2", name: "participant2", speakerOrder: -1)
        let participant3 = Participant(id: "id3", name: "participant3", speakerOrder: -1)

        let allParticipants = [participant1, participant2, participant3]
        // Fake call this block
        // In the real world , the firebase callback will call this block
        fakeReferenceObserver.participantListChangedSubscriber!(allParticipants)
        XCTAssertEqual(hostDomain.allParticipants, allParticipants)

        let speakingOrderPredicate = NSPredicate { (item, bindings) -> Bool in
            let domain = item as! TeamBoostKitDomain
            return domain.speakerOrder.count == 3 &&
                domain.speakerOrder[0] == "id1"
        }

        let expectation = self.expectation(for: speakingOrderPredicate,
                                           evaluatedWith: hostDomain,
                                           handler: nil)

        hostDomain.startMeeting()
        // Initialising it simply starts the timers
        let hostMeetingControllerService = HostMeetingControllerService(meetingParams: hostDomain.meetingParams,
                                                                        orderObserver: fakeSpeakerOrderObserver,
                                                                        meetingMode: .AutoModerated,
                                                                        domain: hostDomain)
        hostMeetingControllerService.startParticipantSpeakingSessions()

        // Verify that the participants are added to the meeting
        self.wait(for: [expectation], timeout: 2.0)

        // After 4 seconds the speaker should switch
        let firstSpeakerSwitchPredicate = NSPredicate { (item, bindings) -> Bool in
            let domain = item as! TeamBoostKitDomain
            return domain.speakerOrder[0] == "id2"
        }

        let firstSpeakerSwitchExpectation = self.expectation(for: firstSpeakerSwitchPredicate,
                                                             evaluatedWith: hostDomain,
                                                             handler: nil)

        self.wait(for: [firstSpeakerSwitchExpectation], timeout: 5.0)

        // Then the speaker should change again
        let secondSpeakerSwitchPredicate = NSPredicate { (item, bindings) -> Bool in
            let domain = item as! TeamBoostKitDomain
            return domain.speakerOrder[0] == "id3"
        }

        let secondSpeakerSwitchExpectation = self.expectation(for: secondSpeakerSwitchPredicate,
                                                              evaluatedWith: hostDomain,
                                                              handler: nil)

        self.wait(for: [secondSpeakerSwitchExpectation], timeout: 5.0)

        // To silence the warning
        _ = hostMeetingControllerService
    }

    /**
     A test with auto moderated meeting with three participants with max allowed time of 10 seconds
     The second participant only speaks for 4 seconds then says I am done.
     We wait for the round to complete after which we verify the speaking order of the new round
     */
    func testSimpleAutoMeetingWithRoundsWhereParticipantGetsDone() {
        let totalMeetingTime = 60
        let maxAllowedTalkTime = 10
        // Setup the meeting on the host side
        let meetingParams = MeetingsParams(agenda: "Foo Agenda",
                                           meetingTime: totalMeetingTime,
                                           maxTalkTime: maxAllowedTalkTime,
                                           moderationMode: .AutoModerated)

        let fakeReferenceObserver = FakeReferenceObserver()
        let fakeSpeakerOrderObserver = FakeSpeakerOrderObserver()

        let hostDomain = TeamBoostKitDomain.make(referenceObserver: fakeReferenceObserver,
                                         referenceHolder: FakeReferenceHolding(),
                                         meetingIdentifier: "meetingId",
                                         meetingParams: meetingParams)

        XCTAssertEqual(hostDomain.meetingIdentifier, "meetingId")
        let participant1 = Participant(id: "id1", name: "participant1", speakerOrder: -1)
        let participant2 = Participant(id: "id2", name: "participant2", speakerOrder: -1)
        let participant3 = Participant(id: "id3", name: "participant3", speakerOrder: -1)

        let allParticipants = [participant1, participant2, participant3]
        // Fake call this block
        // In the real world , the firebase callback will call this block
        fakeReferenceObserver.participantListChangedSubscriber!(allParticipants)
        XCTAssertEqual(hostDomain.allParticipants, allParticipants)

        let speakingOrderPredicate = NSPredicate { (item, bindings) -> Bool in
            let domain = item as! TeamBoostKitDomain
            return domain.speakerOrder.count == 3 &&
                domain.speakerOrder[0] == "id1"
        }

        let expectation = self.expectation(for: speakingOrderPredicate,
                                           evaluatedWith: hostDomain,
                                           handler: nil)

        hostDomain.startMeeting()
        // Initialising it simply starts the timers
        let hostMeetingControllerService = HostMeetingControllerService(meetingParams: meetingParams,
                                                                        orderObserver: fakeSpeakerOrderObserver,
                                                                        meetingMode: .AutoModerated,
                                                                        domain: hostDomain)
        hostMeetingControllerService.startParticipantSpeakingSessions()

        // Verify that the participants are added to the meeting
        self.wait(for: [expectation], timeout: 2.0)

        //1: After 10 seconds the speaker should switch
        let firstSpeakerSwitchPredicate = NSPredicate { (item, bindings) -> Bool in
            let domain = item as! TeamBoostKitDomain
            return domain.speakerOrder[0] == "id2"
        }

        let firstSpeakerSwitchExpectation = self.expectation(for: firstSpeakerSwitchPredicate,
                                                             evaluatedWith: hostDomain,
                                                             handler: nil)

        // Give one second of extra cushion
        self.wait(for: [firstSpeakerSwitchExpectation], timeout: 11.0)

        //2: After 4 seconds, seconds speaker says that she is done!
        let secondSpeakerSwitchPredicate = NSPredicate { (item, bindings) -> Bool in
            let domain = item as! TeamBoostKitDomain
            return domain.speakerOrder[0] != "id2"
        }

        let secondSpeakerSwitchExpectation = self.expectation(for: secondSpeakerSwitchPredicate,
                                                              evaluatedWith: hostDomain,
                                                              handler: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.00, qos: .userInteractive) {
            fakeReferenceObserver.iAmDoneInterruptSubscriber!(6.0)
        }

        self.wait(for: [secondSpeakerSwitchExpectation], timeout: 5.5)

        //3: Participant 3 is given full time to talk
        let thirdSpeakerSwitchPredicate = NSPredicate { (item, bindings) -> Bool in
            let domain = item as! TeamBoostKitDomain
            return domain.speakerOrder[0] != "id3"
        }

        let thirdSpeakerSwitchExpectation = self.expectation(for: thirdSpeakerSwitchPredicate,
                                                             evaluatedWith: hostDomain,
                                                             handler: nil)

        // 4: Wait for third participant to finish speaking and new round app notification
        let notificationName = Notification.Name(AppNotifications.newMeetingRoundStarted.rawValue)
        let notificationExpectation =
            self.expectation(forNotification: notificationName,
                             object: nil, handler: nil)

        self.wait(for: [thirdSpeakerSwitchExpectation, notificationExpectation], timeout: 15.0)

        //5: Observe order in Core Service and check that the first speaker is id2 because she spoke the least
        let newRoundSpeakerOrderPredicate = NSPredicate { (item, bindings) -> Bool in
            let domain = item as! TeamBoostKitDomain
            return domain.speakerOrder[0] == "id2"
        }

        let speakerOrderExpectation = self.expectation(for: newRoundSpeakerOrderPredicate,
                                                       evaluatedWith: hostDomain,
                                                       handler: nil)

        self.wait(for: [speakerOrderExpectation], timeout: 2.0)

        // TODO: Keep this to hold a strong reference to controller service
        _ = hostMeetingControllerService

    }


    /**
     A test with uniform meeting with three participants with max allowed time of 10 seconds
     The second participant only speaks for 4 seconds then says I am done.
     We wait for the round to complete after which we verify the speaking order of the new round
     */
    func testSimpleUniformMeetingWithRoundsWhereParticipantGetsDone() {
        let totalMeetingTime = 60
        let maxAllowedTalkTime = 10
        // Setup the meeting on the host side
        let meetingParams = MeetingsParams(agenda: "Foo Agenda",
                                           meetingTime: totalMeetingTime,
                                           maxTalkTime: maxAllowedTalkTime,
                                           moderationMode: .AutoModerated)

        let fakeReferenceObserver = FakeReferenceObserver()
        let fakeSpeakerOrderObserver = FakeSpeakerOrderObserver()

        let hostDomain = TeamBoostKitDomain.make(referenceObserver: fakeReferenceObserver,
                                         referenceHolder: FakeReferenceHolding(),
                                         meetingIdentifier: "meetingId",
                                         meetingParams: meetingParams)

        XCTAssertEqual(hostDomain.meetingIdentifier, "meetingId")
        let participant1 = Participant(id: "id1", name: "participant1", speakerOrder: -1)
        let participant2 = Participant(id: "id2", name: "participant2", speakerOrder: -1)
        let participant3 = Participant(id: "id3", name: "participant3", speakerOrder: -1)

        let allParticipants = [participant1, participant2, participant3]
        // Fake call this block
        // In the real world , the firebase callback will call this block
        fakeReferenceObserver.participantListChangedSubscriber!(allParticipants)
        XCTAssertEqual(hostDomain.allParticipants, allParticipants)

        let speakingOrderPredicate = NSPredicate { (item, bindings) -> Bool in
            let domain = item as! TeamBoostKitDomain
            return domain.speakerOrder.count == 3 &&
                domain.speakerOrder[0] == "id1"
        }

        let expectation = self.expectation(for: speakingOrderPredicate,
                                           evaluatedWith: hostDomain,
                                           handler: nil)

        hostDomain.startMeeting()
        // Initialising it simply starts the timers
        let hostMeetingControllerService = HostMeetingControllerService(meetingParams: meetingParams,
                                                                        orderObserver: fakeSpeakerOrderObserver,
                                                                        meetingMode: .Uniform,
                                                                        domain: hostDomain)
        hostMeetingControllerService.startParticipantSpeakingSessions()

        // Verify that the participants are added to the meeting
        self.wait(for: [expectation], timeout: 2.0)

        //1: After 10 seconds the speaker should switch
        let firstSpeakerSwitchPredicate = NSPredicate { (item, bindings) -> Bool in
            let domain = item as! TeamBoostKitDomain
            return domain.speakerOrder[0] == "id2"
        }

        let firstSpeakerSwitchExpectation = self.expectation(for: firstSpeakerSwitchPredicate,
                                                             evaluatedWith: hostDomain,
                                                             handler: nil)

        // Give one second of extra cushion
        self.wait(for: [firstSpeakerSwitchExpectation], timeout: 11.0)

        //2: After 4 seconds, seconds speaker says that she is done!
        let secondSpeakerSwitchPredicate = NSPredicate { (item, bindings) -> Bool in
            let domain = item as! TeamBoostKitDomain
            return domain.speakerOrder[0] != "id2"
        }

        let secondSpeakerSwitchExpectation = self.expectation(for: secondSpeakerSwitchPredicate,
                                                              evaluatedWith: hostDomain,
                                                              handler: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.00, qos: .userInteractive) {
            fakeReferenceObserver.iAmDoneInterruptSubscriber!(6.0)
        }

        self.wait(for: [secondSpeakerSwitchExpectation], timeout: 5.5)

        //3: Participant 3 is given full time to talk
        let thirdSpeakerSwitchPredicate = NSPredicate { (item, bindings) -> Bool in
            let domain = item as! TeamBoostKitDomain
            return domain.speakerOrder[0] != "id3"
        }

        let thirdSpeakerSwitchExpectation = self.expectation(for: thirdSpeakerSwitchPredicate,
                                                             evaluatedWith: hostDomain,
                                                             handler: nil)

        self.wait(for: [thirdSpeakerSwitchExpectation], timeout: 11.0)

        //5: Observe order in Core Service , it should not change
        let newRoundSpeakerOrderPredicate = NSPredicate { (item, bindings) -> Bool in
            let domain = item as! TeamBoostKitDomain
            return domain.speakerOrder[0] == "id1"
        }

        let speakerOrderExpectation = self.expectation(for: newRoundSpeakerOrderPredicate,
                                                       evaluatedWith: hostDomain,
                                                       handler: nil)

        self.wait(for: [speakerOrderExpectation], timeout: 2.0)

        let speakingRecordPerRound = hostMeetingControllerService.storage.participantSpeakingRecordPerRound
        XCTAssertEqual(speakingRecordPerRound[0].participantId, "id1")
        XCTAssertEqual(speakingRecordPerRound[0].speakingTime, 10)

        XCTAssertEqual(speakingRecordPerRound[1].participantId, "id2")
        XCTAssertEqual(speakingRecordPerRound[1].speakingTime, 10)

        XCTAssertEqual(speakingRecordPerRound[2].participantId, "id3")
        XCTAssertEqual(speakingRecordPerRound[2].speakingTime, 10)
    }
}
