//
//  CoreServices.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class CoreServices {
    static let shared = CoreServices()
    private var databaseRef: DatabaseReference?

    private init() {
        print("ALOG: CoreServices: Initialiser called")
        FirebaseApp.configure()
        self.databaseRef = Database.database().reference()
    }


}
