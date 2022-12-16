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
            XCTAssertEqual(error as! TokenizingError, TokenizingError.applicationTypeNotPublic)
            
            tokenizeExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
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
        
        waitForExpectations(timeout: 3)
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
            XCTAssertEqual(error as! TokenizingError, TokenizingError.applicationTypeNotPublic)
            
            tokenizeExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
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
        
        waitForExpectations(timeout: 3)
    }
    
    func testProxyRequest() throws {
        let proxyExpectation = self.expectation(description: "Proxy")
        
        // TODO: need to create a new expiring app for testing this...
        let privateApiKey = Configuration.getConfiguration().privateBtApiKey!
        BasisTheoryElements.proxy(
            apiKey: privateApiKey,
            proxyKey: "Y9CGfBNG6rAVnxN7fTiZMb",
            method: .post,
            body: ["testProp": "testValue"])
        { data, error in
            print(data)
            print(error)
            
            proxyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    // TODO: need test for calling proxy without expiring key
    // TODO: need test for calling proxy with different options
}
