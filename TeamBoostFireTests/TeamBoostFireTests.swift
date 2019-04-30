//
//  TeamBoostFireTests.swift
//  TeamBoostFireTests
//
//  Created by Amin Rehman on 30.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import XCTest
@testable import TeamBoostFire

class TeamBoostFireTests: XCTestCase {

    func testSimpleRotate() {
        let sut = ["hello", "there", "how", "are", "you"]
        let result1 = sut.circularRotate()
        XCTAssertEqual(result1, ["there", "how", "are", "you", "hello"])
        let result2 = result1.circularRotate()
        XCTAssertEqual(result2, ["how", "are", "you", "hello", "there"])
    }
}
