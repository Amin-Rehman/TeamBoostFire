//
//  TimerController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 02.09.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

protocol TimerControllerObserver: class {
    func notifyTimerIsDone()
}

protocol TimerController: class {
    var observer: TimerControllerObserver? { get set }
    func start(with interval: Double)
    func stop()
    func isDone()
}

class TeamBoostTimerController: TimerController {
    weak var observer: TimerControllerObserver?

    var timer: Timer?

    func start(with interval: Double) {
        timer = Timer.scheduledTimer(timeInterval: interval, target: self,
                             selector: #selector(self.isDone),
                             userInfo: nil, repeats: false)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    @objc func isDone() {
        observer?.notifyTimerIsDone()
    }
}
