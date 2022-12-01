//
//  ElementUITextFieldTests.swift
//  IntegrationTesterTests
//
//  Created by Brian Gonzalez on 11/11/22.
//

import XCTest
import BasisTheoryElements
import BasisTheory

class ElementUITextFieldTests: XCTestCase {
    private var element: UITextField? = nil
    private var elementInput: String? = nil
    
    override func setUpWithError() throws { }

    override func tearDownWithError() throws { }
    
    override open class var defaultTestSuite: XCTestSuite {
        let testSuite = XCTestSuite(name: NSStringFromClass(self))

        addTestsWithElement(element: TextElementUITextField(), elementInput: "Drewsue Webuino", toTestSuite: testSuite)
        addTestsWithElement(element: CardExpirationDateUITextField(), elementInput: "12/99", toTestSuite: testSuite)
        addTestsWithElement(element: CardVerificationCodeElementUITextField(), elementInput: "123", toTestSuite: testSuite)
        

        return testSuite
    }
    
    private class func addTestsWithElement(element: UITextField, elementInput: String, toTestSuite testSuite: XCTestSuite) {
        testInvocations.forEach { invocation in
            let testCase = ElementUITextFieldTests(invocation: invocation)
            testCase.element = element
            testCase.elementInput = elementInput
            testSuite.addTest(testCase)
        }
    }
    
    func testNilReturnFromTextGetter() throws {
        let possiblyNilTextField = self.element
        
        guard possiblyNilTextField != nil else {
            XCTFail("Run top level test case")
            return
        }
        
        let textField = possiblyNilTextField!
        textField.text = self.elementInput
        
        XCTAssertNil(textField.text)
    }
    
    func testDefaultStylesCanBeSet() throws {
        let possiblyNilTextField = self.element
        
        guard possiblyNilTextField != nil else {
            XCTFail("Run top level test case")
            return
        }
        
        let textField = possiblyNilTextField!
        let expectedBackgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        let expectedCornerRadius = 15.0
        let expectedPlaceholder = "Placeholder"

        textField.backgroundColor = expectedBackgroundColor
        textField.layer.cornerRadius = expectedCornerRadius
        textField.placeholder = expectedPlaceholder
        
        XCTAssertEqual(textField.backgroundColor, expectedBackgroundColor)
        XCTAssertEqual(textField.layer.cornerRadius, expectedCornerRadius)
        XCTAssertEqual(textField.placeholder, expectedPlaceholder)
    }
    
    func testTokenizing() throws {
        let possiblyNilTextField = self.element
        
        guard possiblyNilTextField != nil else {
            XCTFail("Run top level test case")
            return
        }
        
        let textField = possiblyNilTextField!
        textField.text = self.elementInput

        let body: [String: Any] = [
            "data": [
                "textFieldRef": textField,
                "myProp": "myValue",
                "object": [
                    "nestedProp": "nestedValue",
                    "textFieldRef": textField,
                ]
            ],
            "search_indexes": ["{{ data.textFieldRef }}"],
            "type": "token"
        ]

        let publicApiKey = Configuration.getConfiguration().btApiKey!
        let tokenizeExpectation = self.expectation(description: "Tokenize")
        var createdToken: [String: Any] = [:]
        BasisTheoryElements.basePath = "https://api-dev.basistheory.com"
        BasisTheoryElements.tokenize(body: body, apiKey: publicApiKey) { data, error in
            createdToken = data!.value as! [String: Any]

            XCTAssertNotNil(createdToken["id"])
            XCTAssertEqual(createdToken["type"] as! String, "token")

            tokenizeExpectation.fulfill()
        }

        waitForExpectations(timeout: 30, handler: nil)

        let privateApiKey = Configuration.getConfiguration().privateBtApiKey!
        let idQueryExpectation = self.expectation(description: "Token ID Query")
        TokensAPI.getByIdWithRequestBuilder(id: createdToken["id"] as! String).addHeader(name: "BT-API-KEY", value: privateApiKey).execute { result in
            do {
                let token = try result.get().body.data!.value as! [String: Any]

                XCTAssertEqual(token["textFieldRef"] as! String, self.elementInput!)
                XCTAssertEqual(token["myProp"] as! String, "myValue")
                XCTAssertEqual((token["object"] as! [String: String])["nestedProp"], "nestedValue")
                XCTAssertEqual((token["object"] as! [String: String])["textFieldRef"], self.elementInput!)

                idQueryExpectation.fulfill()
            } catch {
                print(error)
            }
        }

        waitForExpectations(timeout: 3, handler: nil)
    }

    func testPostTokens() throws {
        
        let possiblyNilTextField = self.element
        
        guard possiblyNilTextField != nil else {
            XCTFail("Run top level test case")
            return
        }
        
        let textField = possiblyNilTextField!
        textField.text = self.elementInput

        let body: CreateToken = CreateToken(type: "token", data: [
                "textFieldRef": textField,
                "myProp": "myValue",
                "object": [
                    "nestedProp": "nestedValue",
                    "textFieldRef": textField,
                ]
        ])
        
        let apiKey = Configuration.getConfiguration().btApiKey!
        let tokenizeExpectation = self.expectation(description: "Create Token")
        var createdToken: CreateTokenResponse? = nil
        BasisTheoryElements.basePath = "https://api-dev.basistheory.com"
        BasisTheoryElements.createToken(body: body, apiKey: apiKey) { data, error in
            createdToken = data

            XCTAssertNotNil(createdToken!.id)
            XCTAssertEqual(createdToken!.type!, "token")

            tokenizeExpectation.fulfill()
        }

        waitForExpectations(timeout: 3, handler: nil)

        let idQueryExpectation = self.expectation(description: "Token ID Query")
        let privateApiKey = Configuration.getConfiguration().privateBtApiKey!
        TokensAPI.getByIdWithRequestBuilder(id: createdToken!.id!).addHeader(name: "BT-API-KEY", value: privateApiKey).execute { result in
            do {
                let token = try result.get().body.data!.value as! [String: Any]

                XCTAssertEqual(token["textFieldRef"] as! String, self.elementInput!)
                XCTAssertEqual(token["myProp"] as! String, "myValue")
                XCTAssertEqual((token["object"] as! [String: String])["nestedProp"], "nestedValue")
                XCTAssertEqual((token["object"] as! [String: String])["textFieldRef"], self.elementInput!)

                idQueryExpectation.fulfill()
            } catch {
                print(error)
            }
        }

        waitForExpectations(timeout: 3, handler: nil)
    }
}
