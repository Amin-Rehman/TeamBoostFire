//
//  ParticipantPersisted.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 14.03.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import Foundation

public class ParticipantPersisted: NSObject {
    let id: String
    let name: String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
