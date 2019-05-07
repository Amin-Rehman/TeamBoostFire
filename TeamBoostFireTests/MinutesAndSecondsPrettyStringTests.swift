//
//  MinutesAndSecondsPrettyStringTests.swift
//  TeamBoostFireTests
//
//  Created by Amin Rehman on 07.05.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import XCTest
@testable import TeamBoostFire

class MinutesAndSecondsPrettyStringTests: XCTestCase {

    func testLessThanTenSeconds() {
        let seconds = 9
        XCTAssertEqual(seconds.minutesAndSecondsPrettyString(),"00:09")
    }

    func testMoreThanTenSeconds() {
        let seconds = 34
        XCTAssertEqual(seconds.minutesAndSecondsPrettyString(),"00:34")
    }

    func testMoreThanSixtySeconds() {
        let seconds = 74
        XCTAssertEqual(seconds.minutesAndSecondsPrettyString(),"01:14")
    }

    func testMoreThanThreeThousandSixHundred() {
        let seconds = 3714
        XCTAssertEqual(seconds.minutesAndSecondsPrettyString(),"61:54")
    }

}
