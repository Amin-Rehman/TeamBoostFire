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

    private var firebaseReferenceHolder: FirebaseReferenceHolder?
    private var firebaseReferenceObserver: FirebaseReferenceObserver?

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
        self.firebaseReferenceHolder = FirebaseReferenceHolder(with: meetingIdentifier!)
        firebaseReferenceHolder?.participantsReference?.child(participant.id).setValue(
            ["name": participant.name,
             "id":participant.id])

        guard let firebaseReferenceHolder = self.firebaseReferenceHolder else {
            assertionFailure("fireBaseReferenceContainer unable to be initialised")
            return
        }

        firebaseReferenceObserver = FirebaseReferenceObserver(with: firebaseReferenceHolder)
        firebaseReferenceObserver?.setObserver(teamBoostCore: self)
        
        firebaseReferenceObserver?.observeParticipantListChanges()
        firebaseReferenceObserver?.observeMeetingStateDidChange()
        firebaseReferenceObserver?.observeSpeakerOrderDidChange()
        firebaseReferenceObserver?.observeMeetingParamsDidChange()
    }

    public func registerParticipantIsDoneInterrupt() {
        let timeStampOfInterrupt = Date().timeIntervalSinceReferenceDate
        firebaseReferenceHolder?.iAmDoneInterruptReference?.setValue(timeStampOfInterrupt)
    }
}
