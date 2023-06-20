//
//  HttpClientTests.swift
//  UnitTests
//
//  Created by Brian Gonzalez on 6/20/23.
//

import XCTest
import BasisTheoryElements
import BasisTheory

final class HttpClientTests: XCTestCase {
    private final var TIMEOUT_EXPECTATION = 5.0
    
    override func setUpWithError() throws { }
    
    override func tearDownWithError() throws { }
    
    func testPostRequest() throws {
        let textElement = TextElementUITextField()
        textElement.insertText("test element value")
        
        var payload = [
            "textElementProp": textElement,
            "plainTextProp": "plaintext value",
            "object" : [
                "nestedProp": "nested value"
            ]
        ] as [String : Any]
        var config = Config(headers: [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-Test-Header": "test header value"
        ])
        
        let postHttpClientExpectation = self.expectation(description: "POST HTTP client")
        BasisTheoryElements.post(url: "https://echo.basistheory.com/anything", payload: payload, config: config) { request, data, error in
            XCTAssertNil(error)
            XCTAssertEqual(data?.json?.textElementProp?.rawValue as! String, "test element value")
            XCTAssertEqual(data?.json?.plainTextProp?.rawValue as! String, "plaintext value")
            XCTAssertEqual(data?.json?.object?.nestedProp?.rawValue as! String, "nested value")
            
            postHttpClientExpectation.fulfill()
        }
        
        waitForExpectations(timeout: TIMEOUT_EXPECTATION)
    }
    
    func testPutRequest() throws {}
    
    func testPatchRequest() throws {}
    
    func testGetRequest() throws {}
    
    func testDeleteRequest() throws {}
}
