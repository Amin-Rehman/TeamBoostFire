//  Created by Amin Rehman on 30.05.19.

import Foundation
import Firebase
import FirebaseDatabase

class ParticipantCoreServices: TeamBoostCore {
    var speakerOrder: [String]?
    var allParticipants: [Participant]?
    var meetingParams: MeetingsParams?

    static let shared = ParticipantCoreServices()
    private(set) public var meetingIdentifier: String?
    private(set) public var selfParticipantIdentifier: String?

    private var firebaseReferenceContainer: FirebaseReferenceContainer?
    private var firebaseObserverUtility: FirebaseObserverUtility?

    private init() {}

    public func setupCore(with participant: Participant,
                          meetingCode: String) {
        print("ALOG: ParticipantCoreServices: setupCore called")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.testEnvironment == true {
            self.meetingIdentifier = StubMeetingVars.MeetingCode.rawValue
        } else {
            self.meetingIdentifier = meetingCode
        }
        selfParticipantIdentifier = participant.id
        self.firebaseReferenceContainer = FirebaseReferenceContainer(with: meetingIdentifier!)
        firebaseReferenceContainer?.participantsReference?.child(participant.id).setValue(["name": participant.name,
                                                                                           "id":participant.id])

        guard let firebaseReferenceContainer = self.firebaseReferenceContainer else {
            assertionFailure("fireBaseReferenceContainer unable to be initialised")
            return
        }

        firebaseObserverUtility = FirebaseObserverUtility(with: firebaseReferenceContainer,
                                                          teamBoostCore: self)
        firebaseObserverUtility?.observeParticipantListChanges()
        firebaseObserverUtility?.observeMeetingStateDidChange()
        firebaseObserverUtility?.observeSpeakerOrderDidChange()
        firebaseObserverUtility?.observeMeetingParamsDidChange()
    }

    public func registerParticipantIsDoneInterrupt() {
        let timeStampOfInterrupt = Date().timeIntervalSinceReferenceDate


        firebaseReferenceContainer?.iAmDoneInterruptReference?.setValue(timeStampOfInterrupt)
    }
}
