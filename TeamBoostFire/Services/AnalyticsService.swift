//
//  AnalyticsService.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 09.06.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation
import Mixpanel

class AnalyticsService {
    let mixpanel: Mixpanel?
    static let shared = AnalyticsService()

    private init() {
        switch Config.appConfiguration {
        case .TestFlight, .AppStore:
            self.mixpanel =
                Mixpanel.init(token: "0f4dfa8e0b1d6dfeab99c3225f4457af", andFlushInterval: 10)
        case .Debug:
            self.mixpanel = nil
        }
    }

    public func hostMeetingStarted() {
        mixpanel?.track("host_meeting_started")
    }

    public func hostMeetingEnded() {
        mixpanel?.track("host_meeting_ended")
    }

    public func hostMeetingCompleted() {
        mixpanel?.track("host_meeting_completed")
    }

    public func participantCalledSpeaker() {
        mixpanel?.track("participant_called_speaker")
    }

    public func participantIsDone() {
        mixpanel?.track("participant_is_done")
    }

}
