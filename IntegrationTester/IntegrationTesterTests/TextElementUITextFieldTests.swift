//
//  IntegrationTesterTests.swift
//  IntegrationTesterTests
//
//  Created by Brian Gonzalez on 10/18/22.
//

import XCTest
import BasisTheoryElements
import BasisTheory
import Combine

final class TextElementUITextFieldTests: XCTestCase {

    override func setUpWithError() throws { }

    override func tearDownWithError() throws { }

    func testNilReturnFromText() throws {
        let textField = TextElementUITextField()
        textField.text = "Drewsue Webuino"
        
        XCTAssertNil(textField.text)
    }
    
    func testDefaultStylesCanBeSet() throws {
        let expectedBackgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        let expectedCornerRadius = 15.0
        let expectedPlaceholder = "Placeholder"
        
        let textField = TextElementUITextField()
        textField.backgroundColor = expectedBackgroundColor
        textField.layer.cornerRadius = expectedCornerRadius
        textField.placeholder = expectedPlaceholder
        
        XCTAssertEqual(textField.backgroundColor, expectedBackgroundColor)
        XCTAssertEqual(textField.layer.cornerRadius, expectedCornerRadius)
        XCTAssertEqual(textField.placeholder, expectedPlaceholder)
    }
    
    func testTokenizing() throws {
        let nameTextField = TextElementUITextField()
        nameTextField.text = "Drewsue Webuino"
        
        
        let phoneNumberTextField = TextElementUITextField()
        phoneNumberTextField.text = "555-123-4567"
        
        let body: [String: Any] = [
            "data": [
                "name": nameTextField,
                "phoneNumber": phoneNumberTextField,
                "myProp": "myValue",
                "object": [
                    "nestedProp": "nestedValue",
                    "phoneNumber": phoneNumberTextField,
                ]
            ],
            "search_indexes": ["{{ data.phoneNumber }}"],
            "type": "token"
        ]
        
        let apiKey = Configuration.getConfiguration().btApiKey!
        let tokenizeExpectation = self.expectation(description: "Tokenize")
        var createdToken: [String: Any] = [:]
        BasisTheoryElements.basePath = "https://api-dev.basistheory.com"
        BasisTheoryElements.tokenize(body: body, apiKey: apiKey) { data, error in
            createdToken = data!.value as! [String: Any]

            XCTAssertNotNil(createdToken["id"])
            XCTAssertEqual(createdToken["type"] as! String, "token")
            
            tokenizeExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)
        
        let idQueryExpectation = self.expectation(description: "Token ID Query")
        TokensAPI.getByIdWithRequestBuilder(id: createdToken["id"] as! String).addHeader(name: "BT-API-KEY", value: apiKey).execute { result in
            do {
                let token = try result.get().body.data!.value as! [String: Any]

                XCTAssertEqual(token["name"] as! String, "Drewsue Webuino")
                XCTAssertEqual(token["phoneNumber"] as! String, "555-123-4567")
                XCTAssertEqual(token["myProp"] as! String, "myValue")
                XCTAssertEqual((token["object"] as! [String: String])["nestedProp"], "nestedValue")
                XCTAssertEqual((token["object"] as! [String: String])["phoneNumber"], "555-123-4567")

                idQueryExpectation.fulfill()
            } catch {
                print(error)
            }
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testEvents() throws {
        let nameTextField = TextElementUITextField()
        
        let nameInputExpectation = self.expectation(description: "Name input")
        let nameDeleteExpectation = self.expectation(description: "Name delete")
        var cancellables = Set<AnyCancellable>()
        nameTextField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            if (!message.empty) {
                nameInputExpectation.fulfill()
            } else {
                nameDeleteExpectation.fulfill()
            }
        }.store(in: &cancellables)

        nameTextField.insertText("Drewsue Webuino")
        nameTextField.text = ""
        nameTextField.insertText("")
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
