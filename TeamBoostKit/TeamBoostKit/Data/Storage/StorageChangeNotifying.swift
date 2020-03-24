//
//  StorageChangeNotifying.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 08.03.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import Foundation

protocol StorageChangeObserving: class {
    func storageDidChange()
}
