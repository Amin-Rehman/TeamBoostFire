//
//  ReferenceObserving.swift
//  TeamBoostKit
//
//  Created by Amin Rehman on 24.03.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import Foundation

public protocol ReferenceObserving {
    func observeSpeakerOrderDidChange(subscriber: @escaping ([String]) -> Void)
    func observeParticipantListChanges(subscriber: @escaping ([Participant]) -> Void)
    func observeIAmDoneInterrupt(subscriber: @escaping (TimeInterval) -> Void)
    func observeMeetingStateDidChange(subscriber: @escaping (MeetingState) -> Void)
    func observeMeetingParamsDidChange(subscriber: @escaping (MeetingsParams) -> Void)
    func observeCallToSpeakerDidChange(subscriber: @escaping (String) -> Void)
    func observeModeratorHasControlDidChange(subscriber: @escaping (Bool) -> Void)
    func disconnectAll()
}
