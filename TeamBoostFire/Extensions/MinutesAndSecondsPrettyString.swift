//
//  SecondsPrettyString.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 07.05.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

extension Int {
    func minutesAndSecondsPrettyString() -> String {
        let seconds = self % 3600
        let minutes = self / 3600

        var secondsString: String
        var minutesString: String

        if seconds < 10 {
            secondsString = "0" + String(seconds)
        } else {
            secondsString = String(seconds)
        }

        if minutes < 10 {
            minutesString = "0" + String(minutes)
        } else {
            minutesString = String(minutes)
        }

        return minutesString + ":" + secondsString
    }
}


