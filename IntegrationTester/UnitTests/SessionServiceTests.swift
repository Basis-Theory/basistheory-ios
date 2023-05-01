//
//  SessionServiceTests.swift
//  UnitTests
//
//  Created by Brian Gonzalez on 1/10/23.
//

import XCTest
import BasisTheoryElements
import BasisTheory

final class SessionServiceTests: XCTestCase {
    private final var TIMEOUT_EXPECTATION = 3.0
    
    override func setUpWithError() throws {
        BasisTheoryAPI.basePath = "https://api.flock-dev.com"
    }
    
    override func tearDownWithError() throws { }
    
    func testCreatingASession() throws {
        let btApiKey = Configuration.getConfiguration().btApiKey!
        
        let createSessionExpectation = self.expectation(description: "Create session")
        BasisTheoryElements.createSession(apiKey: btApiKey) { data, error in
            XCTAssertNil(error)
            XCTAssertNotNil(data?.sessionKey)
            XCTAssertNotNil(data?.nonce)
            XCTAssertNotNil(data?.expiresAt)
            
            createSessionExpectation.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT_EXPECTATION)
    }
}
