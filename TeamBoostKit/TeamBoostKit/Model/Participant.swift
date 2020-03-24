//
//  Participant.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

public struct Participant: Equatable {
    public let id: String
    public let name: String
    // TODO: This is probably redundant: To be removed
    public var speakerOrder: Int

    public init(id: String,
                name: String,
                speakerOrder: Int) {
        self.id = id
        self.name = name
        self.speakerOrder = speakerOrder
    }
}
