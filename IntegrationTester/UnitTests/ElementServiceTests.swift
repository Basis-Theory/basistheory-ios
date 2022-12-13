//
//  ElementServiceTests.swift
//  IntegrationTesterTests
//
//  Created by Brian Gonzalez on 11/10/22.
//

import XCTest
import BasisTheoryElements
import BasisTheory

final class ElementServiceTests: XCTestCase {
    override func setUpWithError() throws { }
    
    override func tearDownWithError() throws { }
    
    func testTokenizeChecksForApplicationTypeOfPublic() throws {
        let body: [String: Any] = [
            "myProp": "myValue"
        ]
        
        let privateApiKey = Configuration.getConfiguration().privateBtApiKey!
        let tokenizeExpectation = self.expectation(description: "Tokenize")
        BasisTheoryElements.basePath = "https://api-dev.basistheory.com"
        BasisTheoryElements.tokenize(body: body, apiKey: privateApiKey) { data, error in
            XCTAssertNil(data)
            XCTAssertEqual(error as! TokenizingError, TokenizingError.applicationNotPublic)
            
            tokenizeExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testTokenizeReturnsErrorFromApplicationCheck() throws {
        let body: [String: Any] = [
            "myProp": "myValue"
        ]
        
        let tokenizeExpectation = self.expectation(description: "Tokenize")
        BasisTheoryElements.basePath = "https://api-dev.basistheory.com"
        BasisTheoryElements.tokenize(body: body, apiKey: "bad api key") { data, error in
            XCTAssertNil(data)
            XCTAssertNotNil(error)
            
            tokenizeExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testCreateTokenChecksForApplicationTypeOfPublic() throws {
        let body = CreateToken(type: "token", data: [
            "myProp": "myValue"
        ])
        
        let privateApiKey = Configuration.getConfiguration().privateBtApiKey!
        let tokenizeExpectation = self.expectation(description: "Tokenize")
        BasisTheoryElements.basePath = "https://api-dev.basistheory.com"
        BasisTheoryElements.createToken(body: body, apiKey: privateApiKey) { data, error in
            XCTAssertNil(data)
            XCTAssertEqual(error as! TokenizingError, TokenizingError.applicationNotPublic)
            
            tokenizeExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testCreateReturnsErrorFromApplicationCheck() throws {
        let body = CreateToken(type: "token", data: [
            "myProp": "myValue"
        ])
        
        let tokenizeExpectation = self.expectation(description: "Tokenize")
        BasisTheoryElements.basePath = "https://api-dev.basistheory.com"
        BasisTheoryElements.createToken(body: body, apiKey: "bad api key") { data, error in
            XCTAssertNil(data)
            XCTAssertNotNil(error)
            
            tokenizeExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
}
