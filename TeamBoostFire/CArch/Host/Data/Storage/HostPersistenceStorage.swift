//
//  HostPersistenceStorage.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 02.03.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import Foundation

protocol PersistenceStorage {
    func fetchValue(field: String) -> Any
    func setValue(value: Any, field: String)
    func clear()
}

struct HostPersistenceStorage: PersistenceStorage {
    func fetchValue(field: String) -> Any {
        // To implement
        return ""
    }

    func setValue(value: Any, field: String) {
        // To implement
    }

    func clear() {
        // To Implement
    }
}
