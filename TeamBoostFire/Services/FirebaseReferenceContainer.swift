//  Copyright © 2019 Amin Rehman. All rights reserved.

import Foundation
import Firebase
import FirebaseDatabase

struct FirebaseReferenceContainer {
    private(set) var databaseRef: DatabaseReference?
    private(set) var meetingReference: DatabaseReference?
    private(set) var meetingStateReference: DatabaseReference?
    private(set) var speakerOrderReference: DatabaseReference?
    private(set) var participantsReference: DatabaseReference?
    private(set) var meetingParamsReference: DatabaseReference?
    private(set) var iAmDoneInterruptReference: DatabaseReference?
    private(set) var meetingParamsTimeReference: DatabaseReference?
    private(set) var meetingParamsMaxTalkingTimeReference: DatabaseReference?
    private(set) var meetingParamsAgendaReference: DatabaseReference?

    init(with meetingIdentifier: String) {
        FirebaseApp.configure()
        self.databaseRef = Database.database().reference()
        self.meetingReference = self.databaseRef?.child(meetingIdentifier)
        self.meetingStateReference = self.meetingReference?.referenceOfChild(with: .MeetingState)
        self.speakerOrderReference = self.meetingReference?.referenceOfChild(with: .SpeakerOrder)
        self.participantsReference = self.meetingReference?.referenceOfChild(with: .Participants)
        self.meetingParamsReference = self.meetingReference?.referenceOfChild(with: .MeetingParams)
        self.iAmDoneInterruptReference = self.meetingReference?.referenceOfChild(with: .IAmDoneInterrupt)
        self.meetingParamsTimeReference = self.meetingParamsReference?.referenceOfChild(with: .MeetingTime)
        self.meetingParamsAgendaReference = self.meetingParamsReference?.referenceOfChild(with: .Agenda)
        self.meetingParamsMaxTalkingTimeReference = self.meetingParamsReference?.referenceOfChild(with: .MaxTalkTime)
    }
}

extension DatabaseReference {
    func referenceOfChild(with key: TableKeys) -> DatabaseReference {
        return self.child(key.rawValue)
    }
}
