//
//  ParticipantPersisted.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 14.03.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import Foundation

enum ParticipantPersistedSecureKeys: String {
  case id = "Id"
  case name = "Name"
}

@objc(ParticipantPersisted)
public class ParticipantPersisted: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true

    let id: String
    let name: String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    public required init?(coder: NSCoder) {
        self.id = coder.decodeObject(forKey: ParticipantPersistedSecureKeys.id.rawValue) as! String
        self.name = coder.decodeObject(forKey: ParticipantPersistedSecureKeys.name.rawValue) as! String
    }

    public func encode(with coder: NSCoder) {
        coder.encode(id, forKey: ParticipantPersistedSecureKeys.id.rawValue)
        coder.encode(name, forKey: ParticipantPersistedSecureKeys.name.rawValue)
    }

}
