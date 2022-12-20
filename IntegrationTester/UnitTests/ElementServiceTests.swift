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
    
    // TODO: rename test and focus
    func testProxyRequest() throws {
        let proxyExpectation = self.expectation(description: "Proxy")
        
        let privateBtApiKey = Configuration.getConfiguration().privateBtApiKey!
        
        let createApplicationRequest = CreateApplicationRequest(name: "Expiring API key", type: "expiring", permissions: ["token:use"])
        BasisTheoryAPI.basePath = "https://api-dev.basistheory.com"
        ApplicationsAPI.createWithRequestBuilder(createApplicationRequest: createApplicationRequest).addHeader(name: "BT-API-KEY", value: privateBtApiKey).execute { result in
            switch result {
            case .failure(let ErrorResponse.error(e)):
                print(try! JSONSerialization.jsonObject(with: e.1!, options: []))
            case .success(_):
                print("success")
            }
            
            let expiringApiKey = try! result.get().body.key!
            let proxyHttpRequest = ProxyHttpRequest(method: .post, body: ["testProp": "testValue"])
            
            BasisTheoryElements.proxy(
                apiKey: expiringApiKey,
                proxyKey: "Y9CGfBNG6rAVnxN7fTiZMb",
                proxyHttpRequest: proxyHttpRequest)
            { response, data, error in
                print(response)
                print(data?.json?["User-Agent"]?.elementValueReference)
                print(data?.headers?.testProp?.elementValueReference)
                print(error)
                
                proxyExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 30)
    }
    
    // TODO: need test for calling proxy without expiring key
    // TODO: need test for calling proxy without a body
    // TODO: need test for calling proxy without a proxy key/with a proxy url
    // TODO: need test for calling proxy with valid url
    // TODO: need test for calling proxy with invalid url
    // TODO: need test for calling proxy with headers
}
