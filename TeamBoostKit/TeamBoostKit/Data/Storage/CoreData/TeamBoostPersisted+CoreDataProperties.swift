//
//  TeamBoostPersisted+CoreDataProperties.swift
//  
//
//  Created by Amin Rehman on 04.03.20.
//
//

import Foundation
import CoreData


extension TeamBoostPersisted {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TeamBoostPersisted> {
        return NSFetchRequest<TeamBoostPersisted>(entityName: "TeamBoostPersisted")
    }

    @NSManaged public var meetingIdentifier: String?
    @NSManaged public var callToSpeakerInterrupt: String?
    @NSManaged public var currentSpeakerSpeakingTime: Int64
    @NSManaged public var iAmDoneInterrupt: NSNumber?
    @NSManaged public var meetingParamsAgenda: String?
    @NSManaged public var meetingParamsMaxTalkTime: Int64
    @NSManaged public var meetingParamsMeetingTime: Int64
    @NSManaged public var meetingState: String?
    @NSManaged public var moderatorHasControl: Bool
    @NSManaged public var participants: [ParticipantPersisted]?
    @NSManaged public var speakerOrder: [String]?

    @NSManaged public var meetingIdentifierChanged: NSNumber?
    @NSManaged public var callToSpeakerInterruptChanged: NSNumber?
    @NSManaged public var currentSpeakerSpeakingTimeChanged: NSNumber?
    @NSManaged public var iAmDoneInterruptChanged: NSNumber?
    @NSManaged public var meetingParamsAgendaChanged: NSNumber?
    @NSManaged public var meetingParamsMaxTalkTimeChanged: NSNumber?
    @NSManaged public var meetingParamsMeetingTimeChanged: NSNumber?
    @NSManaged public var meetingStateChanged: NSNumber?
    @NSManaged public var moderatorHasControlChanged: NSNumber?
    @NSManaged public var participantsChanged: NSNumber?
    @NSManaged public var speakerOrderChanged: NSNumber?

}
