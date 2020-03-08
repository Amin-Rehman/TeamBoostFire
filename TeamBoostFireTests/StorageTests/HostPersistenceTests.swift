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
    
    func testSaveAndRetrieveCallToSpeakerInterruptLocalChange() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)
        
        sut.setCallToSpeakerInterrupt(callToSpeakerInterrupt: "foo",
                                      meetingIdentifier: stubMeetingIdentifier,
                                      localChange: true)
        
        let callToSpeakerValuePair = sut.callToSpeakerInterrupt(for: stubMeetingIdentifier)
        XCTAssertEqual(callToSpeakerValuePair.value, "foo")
        XCTAssertGreaterThan(callToSpeakerValuePair.timestamp.doubleValue, 0.0)
    }
    
    func testSaveAndRetrieveCallToSpeakerInterrupt() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)
        
        sut.setCallToSpeakerInterrupt(callToSpeakerInterrupt: "foo",
                                      meetingIdentifier: stubMeetingIdentifier,
                                      localChange: false)
        let callToSpeakerValuePair = sut.callToSpeakerInterrupt(for: stubMeetingIdentifier)
        XCTAssertEqual(callToSpeakerValuePair.value, "foo")
        XCTAssertEqual(callToSpeakerValuePair.timestamp.doubleValue, 0.0)
    }
    
    func testCurrentSpeakerSpeakingTimeLocalChange() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)
        
        sut.setCurrentSpeakerSpeakingTime(currentSpeakerSpeakingTime: 200,
                                          meetingIdentifier: stubMeetingIdentifier,
                                          localChange: true)
        
        let currentSpeakerSpeakingTimeValuePair = sut.currentSpeakerSpeakingTime(for: stubMeetingIdentifier)
        XCTAssertEqual(currentSpeakerSpeakingTimeValuePair.value, 200)
        XCTAssertGreaterThan(currentSpeakerSpeakingTimeValuePair.timestamp.doubleValue, 0.0)
    }
    
    func testCurrentSpeakerSpeakingTime() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)
        
        sut.setCurrentSpeakerSpeakingTime(currentSpeakerSpeakingTime: 200,
                                          meetingIdentifier: stubMeetingIdentifier,
                                          localChange: false)
        
        let currentSpeakerSpeakingTimeValuePair = sut.currentSpeakerSpeakingTime(for: stubMeetingIdentifier)
        XCTAssertEqual(currentSpeakerSpeakingTimeValuePair.value, 200)
        XCTAssertEqual(currentSpeakerSpeakingTimeValuePair.timestamp.doubleValue, 0.0)
    }
    
    func testMeetingParamsAgendaLocalChange() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)
        
        sut.setMeetingParamsAgenda(agenda: "stub-agenda",
                                   meetingIdentifier: stubMeetingIdentifier,
                                   localChange: true)
        
        let currentSpeakerSpeakingTimeValuePair = sut.meetingParamsAgenda(for: stubMeetingIdentifier)
        XCTAssertEqual(currentSpeakerSpeakingTimeValuePair.value, "stub-agenda")
        XCTAssertGreaterThan(currentSpeakerSpeakingTimeValuePair.timestamp.doubleValue, 0.0)
    }
    
    func testMeetingParamsAgenda() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)
        
        sut.setMeetingParamsAgenda(agenda: "stub-agenda",
                                   meetingIdentifier: stubMeetingIdentifier,
                                   localChange: false)
        
        let currentSpeakerSpeakingTimeValuePair = sut.meetingParamsAgenda(for: stubMeetingIdentifier)
        XCTAssertEqual(currentSpeakerSpeakingTimeValuePair.value, "stub-agenda")
        XCTAssertEqual(currentSpeakerSpeakingTimeValuePair.timestamp.doubleValue, 0.0)
    }
    
    func testSaveAndRetrieveIAmDoneInterruptLocalChange() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)
        
        sut.setIAmDoneInterrupt(iAmDoneInterrupt: "stub-interrupt",
                                meetingIdentifier: stubMeetingIdentifier,
                                localChange: true)
        
        let iAmDoneInterruptValuePair = sut.iAmDoneInterrupt(for: stubMeetingIdentifier)
        XCTAssertEqual(iAmDoneInterruptValuePair.value, "stub-interrupt")
        XCTAssertGreaterThan(iAmDoneInterruptValuePair.timestamp.doubleValue, 0.0)
    }
    
    func testSaveAndRetrieveIAmDoneInterrupt() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)
        
        sut.setIAmDoneInterrupt(iAmDoneInterrupt: "stub-interrupt",
                                meetingIdentifier: stubMeetingIdentifier,
                                localChange: false)
        
        let iAmDoneInterruptValuePair = sut.iAmDoneInterrupt(for: stubMeetingIdentifier)
        XCTAssertEqual(iAmDoneInterruptValuePair.value, "stub-interrupt")
        XCTAssertEqual(iAmDoneInterruptValuePair.timestamp.doubleValue, 0.0)
    }
    
    func testSaveAndRetrieveMeetingParamsMaxTalkTimeLocalChange() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)
        sut.setMeetingParamsMaxTalkTime(maxTalkTime: 100,
                                        meetingIdentifier: stubMeetingIdentifier,
                                        localChange: true)
        
        let meetingParamsMaxTalkTimeValuePair = sut.meetingParamsMaxTalkTime(for: stubMeetingIdentifier)
        XCTAssertEqual(meetingParamsMaxTalkTimeValuePair.value, 100)
        XCTAssertGreaterThan(meetingParamsMaxTalkTimeValuePair.timestamp.doubleValue, 0.0)
    }
    
    func testSaveAndRetrieveMeetingParamsMaxTalkTime() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)
        sut.setMeetingParamsMaxTalkTime(maxTalkTime: 100,
                                        meetingIdentifier: stubMeetingIdentifier,
                                        localChange: false)
        
        let meetingParamsMaxTalkTimeValuePair = sut.meetingParamsMaxTalkTime(for: stubMeetingIdentifier)
        XCTAssertEqual(meetingParamsMaxTalkTimeValuePair.value, 100)
        XCTAssertEqual(meetingParamsMaxTalkTimeValuePair.timestamp.doubleValue, 0.0)
    }
    
    func testSaveAndRetrieveMeetingStateLocalChange() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)
        sut.setMeetingState(meetingState: "started",
                            meetingIdentifier: stubMeetingIdentifier,
                            localChange: true)
        
        let meetingStateValuePair = sut.meetingState(for: stubMeetingIdentifier)
        XCTAssertEqual(meetingStateValuePair.value, "started")
        XCTAssertGreaterThan(meetingStateValuePair.timestamp.doubleValue, 0.0)
    }
    
    func testSaveAndRetrieveMeetingState() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)
        sut.setMeetingState(meetingState: "started",
                            meetingIdentifier: stubMeetingIdentifier,
                            localChange: true)
        
        let meetingStateValuePair = sut.meetingState(for: stubMeetingIdentifier)
        XCTAssertEqual(meetingStateValuePair.value, "started")
        XCTAssertGreaterThan(meetingStateValuePair.timestamp.doubleValue, 0.0)
        
        sut.setMeetingState(meetingState: "ended",
                            meetingIdentifier: stubMeetingIdentifier,
                            localChange: false)
        
        let meetingStateValuePair2 = sut.meetingState(for: stubMeetingIdentifier)
        XCTAssertEqual(meetingStateValuePair2.value, "ended")
        XCTAssertEqual(meetingStateValuePair2.timestamp.doubleValue, 0.0)
    }
    
    func testSaveAndRetrieveModeratorHasControlLocalChange() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)
        sut.setModeratorHasControl(hasControl: true, meetingIdentifier: stubMeetingIdentifier, localChange:true)
        
        let meetingStateValuePair = sut.moderatorHasControl(for: stubMeetingIdentifier)
        XCTAssertEqual(meetingStateValuePair.value, true)
        XCTAssertGreaterThan(meetingStateValuePair.timestamp.doubleValue, 0.0)
    }
    
    func testSaveAndRetrieveModeratorHasControl() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)
        sut.setModeratorHasControl(hasControl: true, meetingIdentifier: stubMeetingIdentifier, localChange:true)
        
        let meetingStateValuePair = sut.moderatorHasControl(for: stubMeetingIdentifier)
        XCTAssertEqual(meetingStateValuePair.value, true)
        XCTAssertGreaterThan(meetingStateValuePair.timestamp.doubleValue, 0.0)
        
        sut.setModeratorHasControl(hasControl: true, meetingIdentifier: stubMeetingIdentifier, localChange:false)
        let meetingStateValuePair2 = sut.moderatorHasControl(for: stubMeetingIdentifier)
        XCTAssertEqual(meetingStateValuePair2.value, true)
        XCTAssertEqual(meetingStateValuePair2.timestamp.doubleValue, 0.0)
    }
    
    func testSaveAndRetrieveParticipantsLocalChange() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)
        let participantsToBePersisted = ["participants-a",
                                         "participants-b",
                                         "participants-c"]
        
        sut.setParticipants(participants: participantsToBePersisted,
                            meetingIdentifier: stubMeetingIdentifier,
                            localChange: true)
        let participantsValuePair = sut.participants(for: stubMeetingIdentifier)
        XCTAssertEqual(participantsValuePair.value, participantsToBePersisted)
        XCTAssertGreaterThan(participantsValuePair.timestamp.doubleValue, 0.0)
    }
    
    func testSaveAndRetrieveParticipants() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)
        let participantsToBePersisted = ["participants-a",
                                         "participants-b",
                                         "participants-c"]
        
        sut.setParticipants(participants: participantsToBePersisted,
                            meetingIdentifier: stubMeetingIdentifier,
                            localChange: true)
        let participantsValuePair = sut.participants(for: stubMeetingIdentifier)
        XCTAssertEqual(participantsValuePair.value, participantsToBePersisted)
        XCTAssertGreaterThan(participantsValuePair.timestamp.doubleValue, 0.0)
        
        sut.setParticipants(participants: participantsToBePersisted,
                            meetingIdentifier: stubMeetingIdentifier,
                            localChange: false)
        let participantsValuePair2 = sut.participants(for: stubMeetingIdentifier)
        XCTAssertEqual(participantsValuePair2.value, participantsToBePersisted)
        XCTAssertEqual(participantsValuePair2.timestamp.doubleValue, 0.0)
    }
    
    func testSaveAndRetrieveSpeakerOrderLocalChange() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)
        let speakerOrderToBePersisted = ["speaker-a",
                                         "speaker-b",
                                         "speaker-c"]
        sut.setSpeakerOrder(speakerOrder: speakerOrderToBePersisted,
                            meetingIdentifier: stubMeetingIdentifier,
                            localChange: true)
        let speakerOrderValuePair = sut.speakerOrder(for: stubMeetingIdentifier)
        XCTAssertEqual(speakerOrderValuePair.value, speakerOrderToBePersisted)
        XCTAssertGreaterThan(speakerOrderValuePair.timestamp.doubleValue, 0.0)
    }
    
    func testSaveAndRetrieveSpeakerOrder() {
        let results1 = sut.fetchAll()
        XCTAssertEqual(results1.count, 0)
        let stubMeetingIdentifier = "stub-meeting-identifier"
        sut.setMeeting(with: stubMeetingIdentifier)
        let results2 = sut.fetchAll()
        XCTAssertEqual(results2.count, 1)
        let speakerOrderToBePersisted = ["speaker-a",
                                         "speaker-b",
                                         "speaker-c"]
        sut.setSpeakerOrder(speakerOrder: speakerOrderToBePersisted,
                            meetingIdentifier: stubMeetingIdentifier,
                            localChange: true)
        let speakerOrderValuePair = sut.speakerOrder(for: stubMeetingIdentifier)
        XCTAssertEqual(speakerOrderValuePair.value, speakerOrderToBePersisted)
        XCTAssertGreaterThan(speakerOrderValuePair.timestamp.doubleValue, 0.0)
        
        sut.setSpeakerOrder(speakerOrder: speakerOrderToBePersisted,
                            meetingIdentifier: stubMeetingIdentifier,
                            localChange: false)
        
        let speakerOrderValuePair2 = sut.speakerOrder(for: stubMeetingIdentifier)
        XCTAssertEqual(speakerOrderValuePair2.value, speakerOrderToBePersisted)
        XCTAssertEqual(speakerOrderValuePair2.timestamp.doubleValue, 0.0)
    }
}
