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
        let proxyKey = "Y9CGfBNG6rAVnxN7fTiZMb"
        var proxyResponseData: JSON = JSON.dictionaryValue([:])
        let proxyHttpRequest = ProxyHttpRequest(method: .post, body: [
            "testProp": "testValue",
            "objProp": [
                "nestedTestProp": "nestedTestValue"
            ]
        ])
        BasisTheoryElements.proxy(
            apiKey: expiringApiKey,
            proxyKey: proxyKey,
            proxyHttpRequest: proxyHttpRequest)
        { response, data, error in
            XCTAssertNil(error)
            XCTAssertEqual(response?.url?.absoluteString, "https://api-dev.basistheory.com/proxy")
            
            let httpResponse = response as! HTTPURLResponse
            
            XCTAssertEqual(httpResponse.statusCode, 200)
            
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
    
    func testProxyReturnsNilValuesFromResponse() throws {
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
        let proxyKey = "Y9CGfBNG6rAVnxN7fTiZMb"
        var proxyResponseData: JSON = JSON.dictionaryValue([:])
        let proxyHttpRequest = ProxyHttpRequest(method: .post, body: [
            "testProp": "testValue",
            "objProp": [
                "nestedTestProp": "nestedTestValue"
            ]
        ])
        BasisTheoryElements.proxy(
            apiKey: expiringApiKey,
            proxyKey: proxyKey,
            proxyHttpRequest: proxyHttpRequest)
        { response, data, error in
            XCTAssertNil(error)
            XCTAssertEqual(response?.url?.absoluteString, "https://api-dev.basistheory.com/proxy")
            
            let httpResponse = response as! HTTPURLResponse
            
            XCTAssertEqual(httpResponse.statusCode, 200)
            
            proxyResponseData = data!
            proxyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
        
        XCTAssertNotNil(proxyResponseData.json?.testProp?.elementValueReference)
        XCTAssertNotNil(proxyResponseData.json?.objProp)
        XCTAssertNil(proxyResponseData.json?.objProp?.elementValueReference)
        XCTAssertNotNil(proxyResponseData.json?.objProp?.nestedTestProp?.elementValueReference)
    }
    
    func testProxyWithoutExpiringKey() {
        let privateBtApiKey = Configuration.getConfiguration().privateBtApiKey!
        
        let proxyExpectation = self.expectation(description: "Proxy")
        let proxyKey = "Y9CGfBNG6rAVnxN7fTiZMb"
        let proxyHttpRequest = ProxyHttpRequest(method: .post, body: [
            "testProp": "testValue",
            "objProp": [
                "nestedTestProp": "nestedTestValue"
            ]
        ])
        BasisTheoryElements.proxy(
            apiKey: privateBtApiKey,
            proxyKey: proxyKey,
            proxyHttpRequest: proxyHttpRequest)
        { response, data, error in
            XCTAssertNil(response)
            XCTAssertNil(data)
            XCTAssertEqual(error as! ProxyError, ProxyError.applicationTypeNotExpiring)
            
            proxyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testProxyWithArrayInBody() {
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
        let proxyKey = "Y9CGfBNG6rAVnxN7fTiZMb"
        var proxyResponseData: JSON = JSON.dictionaryValue([:])
        let proxyHttpRequest = ProxyHttpRequest(method: .post, body: [
            "testProp": [1, 2, 3],
        ])
        BasisTheoryElements.proxy(
            apiKey: expiringApiKey,
            proxyKey: proxyKey,
            proxyHttpRequest: proxyHttpRequest)
        { response, data, error in
            XCTAssertNil(error)
            XCTAssertEqual(response?.url?.absoluteString, "https://api-dev.basistheory.com/proxy")
            
            let httpResponse = response as! HTTPURLResponse
            
            XCTAssertEqual(httpResponse.statusCode, 200)
            
            proxyResponseData = data!
            proxyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
        
        let createTokenExpectation = self.expectation(description: "Create token")
        var createdToken: CreateTokenResponse? = nil
        let body = CreateToken(type: "token", data: [
            "proxyProperty1": proxyResponseData.json?.testProp?[0]?.elementValueReference,
            "proxyProperty2": proxyResponseData.json?.testProp?[1]?.elementValueReference,
            "proxyProperty3": proxyResponseData.json?.testProp?[2]?.elementValueReference,
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
            
            XCTAssertEqual(token["proxyProperty1"] as! String, "1")
            XCTAssertEqual(token["proxyProperty2"] as! String, "2")
            XCTAssertEqual(token["proxyProperty3"] as! String, "3")

            idQueryExpectation.fulfill()
        }

        waitForExpectations(timeout: 3)
    }
    
    func testProxyWithoutABody() {
        let privateBtApiKey = Configuration.getConfiguration().privateBtApiKey!
        
        let applicationExpectation = self.expectation(description: "Create expiring applicaiton")
        var expiringApiKey: String = ""
        let createApplicationRequest = CreateApplicationRequest(name: "Expiring API key", type: "expiring", permissions: ["token:use"])
        ApplicationsAPI.createWithRequestBuilder(createApplicationRequest: createApplicationRequest).addHeader(name: "BT-API-KEY", value: privateBtApiKey).execute { result in
            expiringApiKey = try! result.get().body.key!
            
            applicationExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
        
        let proxyExpectation = self.expectation(description: "Proxy")
        let proxyKey = "AKGRn5nuNw2XqP5Vqh7uYE"
        let proxyHttpRequest = ProxyHttpRequest(method: .get)
        BasisTheoryElements.proxy(
            apiKey: expiringApiKey,
            proxyKey: proxyKey,
            proxyHttpRequest: proxyHttpRequest)
        { response, data, error in
            XCTAssertNil(error)
            XCTAssertEqual(response?.url?.absoluteString, "https://api-dev.basistheory.com/proxy")
            
            let httpResponse = response as! HTTPURLResponse
            
            XCTAssertEqual(httpResponse.statusCode, 200)
            
            proxyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testProxyWithAProxyUrl() {
        let privateBtApiKey = Configuration.getConfiguration().privateBtApiKey!
        
        let applicationExpectation = self.expectation(description: "Create expiring applicaiton")
        var expiringApiKey: String = ""
        let createApplicationRequest = CreateApplicationRequest(name: "Expiring API key", type: "expiring", permissions: ["token:use"])
        ApplicationsAPI.createWithRequestBuilder(createApplicationRequest: createApplicationRequest).addHeader(name: "BT-API-KEY", value: privateBtApiKey).execute { result in
            expiringApiKey = try! result.get().body.key!
            
            applicationExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
        
        let proxyExpectation = self.expectation(description: "Proxy")
        let proxyHttpRequest = ProxyHttpRequest(method: .post, body: [
            "testProp": "testValue",
            "objProp": [
                "nestedTestProp": "nestedTestValue"
            ]
        ])
        BasisTheoryElements.proxy(
            apiKey: expiringApiKey,
            proxyUrl: "https://echo.basistheory.com/post",
            proxyHttpRequest: proxyHttpRequest)
        { response, data, error in
            XCTAssertNil(error)
            XCTAssertEqual(response?.url?.absoluteString, "https://api-dev.basistheory.com/proxy")
            
            let httpResponse = response as! HTTPURLResponse
            
            XCTAssertEqual(httpResponse.statusCode, 200)
            
            proxyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testProxyWithValidUrlForRequest() throws {
        let privateBtApiKey = Configuration.getConfiguration().privateBtApiKey!
        
        let applicationExpectation = self.expectation(description: "Create expiring applicaiton")
        var expiringApiKey: String = ""
        let createApplicationRequest = CreateApplicationRequest(name: "Expiring API key", type: "expiring", permissions: ["token:use"])
        ApplicationsAPI.createWithRequestBuilder(createApplicationRequest: createApplicationRequest).addHeader(name: "BT-API-KEY", value: privateBtApiKey).execute { result in
            expiringApiKey = try! result.get().body.key!
            
            applicationExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
        
        let proxyExpectation = self.expectation(description: "Proxy")
        let proxyKey = "Y9CGfBNG6rAVnxN7fTiZMb"
        let proxyHttpRequest = ProxyHttpRequest(url: "https://api-dev.basistheory.com/proxy", method: .post, body: [
            "testProp": "testValue",
            "objProp": [
                "nestedTestProp": "nestedTestValue"
            ]
        ])
        BasisTheoryElements.proxy(
            apiKey: expiringApiKey,
            proxyKey: proxyKey,
            proxyHttpRequest: proxyHttpRequest)
        { response, data, error in
            XCTAssertNil(error)
            XCTAssertEqual(response?.url?.absoluteString, "https://api-dev.basistheory.com/proxy")
            
            let httpResponse = response as! HTTPURLResponse
            
            XCTAssertEqual(httpResponse.statusCode, 200)
            
            proxyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testProxyWithAnInvalidUrlForRequest() {
        let privateBtApiKey = Configuration.getConfiguration().privateBtApiKey!
        
        let applicationExpectation = self.expectation(description: "Create expiring applicaiton")
        var expiringApiKey: String = ""
        let createApplicationRequest = CreateApplicationRequest(name: "Expiring API key", type: "expiring", permissions: ["token:use"])
        ApplicationsAPI.createWithRequestBuilder(createApplicationRequest: createApplicationRequest).addHeader(name: "BT-API-KEY", value: privateBtApiKey).execute { result in
            expiringApiKey = try! result.get().body.key!
            
            applicationExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
        
        let proxyExpectation = self.expectation(description: "Proxy")
        let proxyKey = "Y9CGfBNG6rAVnxN7fTiZMb"
        let proxyHttpRequest = ProxyHttpRequest(url: "badprotocol://badhost.com/badpath", method: .post, body: [
            "testProp": "testValue",
            "objProp": [
                "nestedTestProp": "nestedTestValue"
            ]
        ])
        BasisTheoryElements.proxy(
            apiKey: expiringApiKey,
            proxyKey: proxyKey,
            proxyHttpRequest: proxyHttpRequest)
        { response, data, error in
            XCTAssertEqual(error as! ProxyError, ProxyError.invalidRequest)
            XCTAssertNil(data)
            XCTAssertNil(response)
            
            proxyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testProxyWithCustomHeader() throws {
        let privateBtApiKey = Configuration.getConfiguration().privateBtApiKey!
        let publicApiKey = Configuration.getConfiguration().btApiKey!
        
        let applicationExpectation = self.expectation(description: "Create expiring applicaiton")
        var proxyResponseData: JSON = JSON.dictionaryValue([:])
        var expiringApiKey: String = ""
        let createApplicationRequest = CreateApplicationRequest(name: "Expiring API key", type: "expiring", permissions: ["token:use"])
        ApplicationsAPI.createWithRequestBuilder(createApplicationRequest: createApplicationRequest).addHeader(name: "BT-API-KEY", value: privateBtApiKey).execute { result in
            expiringApiKey = try! result.get().body.key!
            
            applicationExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
        
        let proxyExpectation = self.expectation(description: "Proxy")
        let proxyKey = "Y9CGfBNG6rAVnxN7fTiZMb"
        let proxyHttpRequest = ProxyHttpRequest(method: .post, headers: [
            "X-Custom-Header": "headerValue",
        ])
        BasisTheoryElements.proxy(
            apiKey: expiringApiKey,
            proxyKey: proxyKey,
            proxyHttpRequest: proxyHttpRequest)
        { response, data, error in
            XCTAssertNil(error)
            XCTAssertEqual(response?.url?.absoluteString, "https://api-dev.basistheory.com/proxy")
            
            let httpResponse = response as! HTTPURLResponse
            
            XCTAssertEqual(httpResponse.statusCode, 200)
            
            proxyResponseData = data!
            proxyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
        
        let createTokenExpectation = self.expectation(description: "Create token")
        var createdToken: CreateTokenResponse? = nil
        let body = CreateToken(type: "token", data: [
            "customHeader": proxyResponseData.headers?["X-Custom-Header"]?.elementValueReference
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
            
            XCTAssertEqual(token["customHeader"] as! String, "headerValue")

            idQueryExpectation.fulfill()
        }

        waitForExpectations(timeout: 3)
    }
    
    func testProxyWithoutApiKey() throws {
        let privateBtApiKey = Configuration.getConfiguration().privateBtApiKey!
        
        let proxyExpectation = self.expectation(description: "Proxy")
        let proxyKey = "Ce3V4ygt9K8snVqSevZEis"
        let proxyHttpRequest = ProxyHttpRequest(method: .get)
        BasisTheoryElements.proxy(
            proxyKey: proxyKey,
            proxyHttpRequest: proxyHttpRequest)
        { response, data, error in
            XCTAssertNil(error)
            XCTAssertEqual(response?.url?.absoluteString, "https://api-dev.basistheory.com/proxy")
            
            let httpResponse = response as! HTTPURLResponse
            
            XCTAssertEqual(httpResponse.statusCode, 200)
            
            proxyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
}
