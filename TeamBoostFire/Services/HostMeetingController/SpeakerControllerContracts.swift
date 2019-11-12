//
//  SpeakerControllerContracts.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 28.08.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

protocol SpeakerControllerOrderObserver: class {
    /**
     Method to indicate that the speaker order has changed and the observer can fetch the new
     order from CoreServices

     Pass in the total speaking time that the observer can use; for example to update the progress view in the cell
     */
    func speakingOrderUpdated(totalSpeakingRecord: [ParticipantId: SpeakingTime])
}

protocol SpeakerControllerSecondTickObserver: class {
    /**
     Indicate that the second ticked for a particular speaker
     */
    func speakerSecondTicked(participantIdentifier: String)
}
