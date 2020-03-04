//
//  ManagedObjectContextFactoryTests.swift
//  TeamBoostFireTests
//
//  Created by Amin Rehman on 04.03.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import XCTest
@testable import TeamBoostFire

class ManagedObjectContextFactoryTests: XCTestCase {
    func testMakingInMemoryStoreIsNotNil() {
        let managedObjectContext = ManagedObjectContextFactory.make()
        XCTAssertNotNil(managedObjectContext)
    }
}
