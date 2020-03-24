//
//  UIViewController+TeamBoost.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 16.03.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import Foundation
import UIKit
import TeamBoostKit

extension UIViewController {
    func getHostDomain() -> TeamBoostKitDomain {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let hostDomain = appDelegate.hostDomain else {
            fatalError("Unable to retrieve hostDomain from Application Delegate")
        }
        return hostDomain
    }
}
