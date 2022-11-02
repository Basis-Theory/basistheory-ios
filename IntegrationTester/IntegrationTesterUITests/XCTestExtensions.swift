//
//  XCTestExtensions.swift
//  IntegrationTesterUITests
//
//  Created by Brian Gonzalez on 11/1/22.
//

import Foundation
import XCTest

extension XCTestCase {
    func wait(interval: TimeInterval = 1 , completion: @escaping (() -> Void)) {
        let exp = expectation(description: "")
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            completion()
            exp.fulfill()
        }
        waitForExpectations(timeout: interval + 0.1) // add 0.1 for sure async after called
    }
}
