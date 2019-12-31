//
//  MeetingControllerSettingTicker.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 27.08.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

/**
 Responsible for updating the meeting time in storage every second
 */

class MeetingTimeUpdater {
    var storage: MeetingControllerStorage
    private var secondTickTimer: Timer?

    init(with storage: MeetingControllerStorage) {
        // First second seems to get missed, so brute force it
        self.storage = storage
        secondTicked()
    }

    @objc private func secondTicked() {
        storage.incrementMeetingTime()
        fireSecondTickedNotification()
    }

    public func start() {
        secondTickTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                               selector: #selector(secondTicked),
                                               userInfo: nil, repeats: true)
    }

    public func stop() {
        secondTickTimer?.invalidate()
        secondTickTimer = nil
    }

    private func fireSecondTickedNotification() {
        DispatchQueue.main.async {
            let name = Notification.Name(AppNotifications.meetingSecondTicked.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: nil)
        }
    }

}
