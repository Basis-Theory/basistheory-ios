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
    override func setUpWithError() throws {
        BasisTheoryAPI.basePath = "https://api-dev.basistheory.com"
    }
    
    override func tearDownWithError() throws { }
    
    func testTokenizeChecksForApplicationTypeOfPublic() throws {
        let body: [String: Any] = [
            "myProp": "myValue"
        ]
        
        let privateApiKey = Configuration.getConfiguration().privateBtApiKey!
        let tokenizeExpectation = self.expectation(description: "Tokenize")
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
        BasisTheoryElements.createToken(body: body, apiKey: "bad api key") { data, error in
            XCTAssertNil(data)
            XCTAssertNotNil(error)
            
            tokenizeExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testProxyRequest() throws {
        let privateBtApiKey = Configuration.getConfiguration().privateBtApiKey!
        let publicApiKey = Configuration.getConfiguration().btApiKey!
        
        let applicationExpectation = self.expectation(description: "Create expiring applicaiton")
        var expiringApiKey: String = ""
        let createApplicationRequest = CreateApplicationRequest(name: "Expiring API key", type: "expiring", permissions: ["token:use"])
        ApplicationsAPI.createWithRequestBuilder(createApplicationRequest: createApplicationRequest).addHeader(name: "BT-API-KEY", value: privateBtApiKey).execute { result in
            expiringApiKey = try! result.get().body.key!
            
            applicationExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
        
        let proxyExpectation = self.expectation(description: "Proxy")
        var proxyResponseData: JSON = JSON.dictionaryValue([:])
        let proxyHttpRequest = ProxyHttpRequest(method: .post, body: [
            "testProp": "testValue",
            "objProp": [
                "nestedTestProp": "nestedTestValue"
            ]
        ])
        BasisTheoryElements.proxy(
            apiKey: expiringApiKey,
            proxyKey: "Y9CGfBNG6rAVnxN7fTiZMb",
            proxyHttpRequest: proxyHttpRequest)
        { response, data, error in
            XCTAssertNil(error)
            // TODO: assert on response
            
            proxyResponseData = data!
            proxyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
        
        let createTokenExpectation = self.expectation(description: "Create token")
        var createdToken: CreateTokenResponse? = nil
        let body = CreateToken(type: "token", data: [
            "proxyProperty": proxyResponseData.json?.testProp?.elementValueReference,
            "nestedProxyProperty": proxyResponseData.json?.objProp?.nestedTestProp?.elementValueReference
        ])
        BasisTheoryElements.createToken(body: body, apiKey: publicApiKey) { data, error in
            XCTAssertNil(error)
            
            createdToken = data!
            
            XCTAssertNotNil(createdToken!.id)
            XCTAssertEqual(createdToken!.type, "token")
            
            createTokenExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
        
        let idQueryExpectation = self.expectation(description: "Token ID Query")
        TokensAPI.getByIdWithRequestBuilder(id: createdToken!.id!).addHeader(name: "BT-API-KEY", value: privateBtApiKey).execute { result in
            let token = try! result.get().body.data!.value as! [String: Any]
            
            XCTAssertEqual(token["proxyProperty"] as! String, "testValue")
            XCTAssertEqual(token["nestedProxyProperty"] as! String, "nestedTestValue")

            idQueryExpectation.fulfill()
        }

        waitForExpectations(timeout: 3)
    }
    
    // TODO: need test for calling proxy without expiring key
    // TODO: need test for calling proxy with array in the body
    // TODO: need test for calling proxy without a body
    // TODO: need test for calling proxy without a proxy key/with a valid proxy url
    // TODO: need test for calling proxy with invalid url
    // TODO: need test for calling proxy with headers
    // TODO: need test for using proxy responses in a tokenize request
    // TODO: need test for using unauthenticated proxy
}
