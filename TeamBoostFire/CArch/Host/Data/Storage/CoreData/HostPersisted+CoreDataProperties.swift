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

    @NSManaged public var callToSpeakerInterrupt: String?
    @NSManaged public var callToSpeakerInterruptChanged: Date?
    @NSManaged public var currentSpeakerSpeakingTime: Int64
    @NSManaged public var currentSpeakerSpeakingTimeChanged: Date?
    @NSManaged public var iAmDoneInterrupt: String?
    @NSManaged public var iAmDoneInterruptChanged: Date?
    @NSManaged public var meetingParamsAgenda: String?
    @NSManaged public var meetingParamsAgendaChanged: Date?
    @NSManaged public var meetingParamsMaxTalkTime: Int64
    @NSManaged public var meetingParamsMaxTalkTimeChanged: Date?
    @NSManaged public var meetingParamsMeetingTime: Int64
    @NSManaged public var meetingParamsMeetingTimeChanged: NSNumber?
    @NSManaged public var meetingState: String?
    @NSManaged public var meetingStateChanged: Date?
    @NSManaged public var moderatorHasControl: Bool
    @NSManaged public var moderatorHasControlChanged: Date?
    @NSManaged public var participants: NSObject?
    @NSManaged public var participantsChanged: Date?
    @NSManaged public var speakerOrder: NSObject?
    @NSManaged public var speakerOrderChanged: Date?
    @NSManaged public var meetingIdentifier: String?
}
