//  Copyright © 2019 Amin Rehman. All rights reserved.

import Foundation
import Firebase
import FirebaseDatabase

public protocol ReferenceHolding {
    func setupDefaultValues(with params: MeetingsParams)
    func setReferenceForMeetingStarted()
    func setReferenceForMeetingEnded()
    func setReferenceForSpeakerOrder(speakingOrder: [String])

    // TODO: Just test mode - to be removed
    func testModeSetReferenceForNoParticipants()
    func testModeSetReferenceForFakeParticipants()
}

/**
 A container which holds references to all the keys in the Firebase database
 */
struct FirebaseReferenceHolder: ReferenceHolding {
    private(set) var databaseRef: DatabaseReference?
    private(set) var meetingReference: DatabaseReference?
    private(set) var meetingStateReference: DatabaseReference?
    private(set) var speakerOrderReference: DatabaseReference?
    private(set) var participantsReference: DatabaseReference?
    private(set) var meetingParamsReference: DatabaseReference?
    private(set) var iAmDoneInterruptReference: DatabaseReference?
    private(set) var currentSpeakerMaximumSpeakingTime: DatabaseReference?
    private(set) var callToSpeakerQueueReference: DatabaseReference?

    private(set) var meetingParamsTimeReference: DatabaseReference?
    private(set) var meetingParamsMaxTalkingTimeReference: DatabaseReference?
    private(set) var meetingParamsAgendaReference: DatabaseReference?

    init(with meetingIdentifier: String) {
        self.databaseRef = Database.database().reference()
        self.meetingReference = self.databaseRef?.child(meetingIdentifier)
        self.meetingStateReference = self.meetingReference?.referenceOfChild(with: .MeetingState)
        self.speakerOrderReference = self.meetingReference?.referenceOfChild(with: .SpeakerOrder)
        self.participantsReference = self.meetingReference?.referenceOfChild(with: .Participants)
        self.meetingParamsReference = self.meetingReference?.referenceOfChild(with: .MeetingParams)
        self.iAmDoneInterruptReference = self.meetingReference?.referenceOfChild(with: .IAmDoneInterrupt)
        self.currentSpeakerMaximumSpeakingTime = self.meetingReference?
            .referenceOfChild(with: .CurrentSpeakerMaxSpeakingTime)
        self.meetingParamsTimeReference = self.meetingParamsReference?.referenceOfChild(with: .MeetingTime)
        self.meetingParamsAgendaReference = self.meetingParamsReference?.referenceOfChild(with: .Agenda)
        self.meetingParamsMaxTalkingTimeReference = self.meetingParamsReference?.referenceOfChild(with: .MaxTalkTime)
        self.callToSpeakerQueueReference = self.meetingReference?.referenceOfChild(with: .CallToSpeakerQueue)
    }

    func setupDefaultValues(with params: MeetingsParams) {
        meetingStateReference?.setValue("suspended")
        speakerOrderReference?.setValue([""])
        meetingParamsReference?.setValue("")
        iAmDoneInterruptReference?.setValue("")
        currentSpeakerMaximumSpeakingTime?.setValue(0)
        meetingParamsTimeReference?.setValue(params.meetingTime)
        meetingParamsAgendaReference?.setValue(params.agenda)
        meetingParamsMaxTalkingTimeReference?.setValue(params.maxTalkTime)
        callToSpeakerQueueReference?.setValue([""])
    }

    func setReferenceForSpeakerOrder(speakingOrder: [String]) {
        speakerOrderReference?.setValue(speakingOrder)
    }

    func setReferenceForMeetingStarted() {
        meetingStateReference?.setValue("started")
    }

    func setReferenceForMeetingEnded() {
        meetingStateReference?.setValue("ended")
    }

    // Test Mode
    func testModeSetReferenceForFakeParticipants() {
        let participantOneId = UUID().uuidString
        participantsReference?
            .child(participantOneId).setValue(["name": "Jon Snow",
                                               "id": participantOneId])

        let participantTwoId = UUID().uuidString
        participantsReference?
            .child(participantTwoId).setValue(["name": "Ned Stark",
                                               "id": participantTwoId])

        let participantThreeId = UUID().uuidString
        participantsReference?
            .child(participantThreeId).setValue(["name": "Cersei Lannister",
                                                 "id": participantThreeId])
    }

    func testModeSetReferenceForNoParticipants() {
        participantsReference?.setValue(nil)
    }


}

extension DatabaseReference {
    func referenceOfChild(with key: TableKeys) -> DatabaseReference {
        return self.child(key.rawValue)
    }
}
