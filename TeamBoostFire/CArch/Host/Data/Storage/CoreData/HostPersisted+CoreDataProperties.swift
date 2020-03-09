//
//  HostPersisted+CoreDataProperties.swift
//  
//
//  Created by Amin Rehman on 04.03.20.
//
//

import Foundation
import CoreData


extension HostPersisted {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<HostPersisted> {
        return NSFetchRequest<HostPersisted>(entityName: "HostPersisted")
    }

    @NSManaged public var meetingIdentifier: String?
    @NSManaged public var callToSpeakerInterrupt: String?
    @NSManaged public var currentSpeakerSpeakingTime: Int64
    @NSManaged public var iAmDoneInterrupt: String?
    @NSManaged public var meetingParamsAgenda: String?
    @NSManaged public var meetingParamsMaxTalkTime: Int64
    @NSManaged public var meetingParamsMeetingTime: Int64
    @NSManaged public var meetingState: String?
    @NSManaged public var moderatorHasControl: Bool
    @NSManaged public var participants: [String]?
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
