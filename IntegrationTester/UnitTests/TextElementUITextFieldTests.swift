//
//  TextElementUITextFieldTests.swift
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
    
    func testEventsWithAndWithoutText() throws {
        let nameTextField = TextElementUITextField()
        
        let nameInputExpectation = self.expectation(description: "Name input")
        let nameDeleteExpectation = self.expectation(description: "Name delete")
        var cancellables = Set<AnyCancellable>()
        nameTextField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            XCTAssertEqual(message.type, "textChange")
            XCTAssertEqual(message.complete, true)
            XCTAssertEqual(message.valid, true)

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
    
    func testCompletionEventWithMask() throws {
        let completeField = TextElementUITextField()
        let incompleteField = TextElementUITextField()
        let regexDigit = try! NSRegularExpression(pattern: "\\d")
        var mask = [regexDigit, regexDigit, regexDigit]
        var options = TextElementOptions(mask: mask)
        
        try! completeField.setConfig(options: options)
        try! incompleteField.setConfig(options: options)
        
        let completeFieldExpectation = self.expectation(description: "Complete field")
        let incompleteFieldExpectation = self.expectation(description: "Incomplete field")
        var cancellables = Set<AnyCancellable>()
        
        completeField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            XCTAssertEqual(message.type, "textChange")
            XCTAssertEqual(message.complete, true)
            XCTAssertEqual(message.valid, true)
            
            completeFieldExpectation.fulfill()
        }.store(in: &cancellables)
        
        incompleteField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            XCTAssertEqual(message.type, "textChange")
            XCTAssertEqual(message.complete, false)
            XCTAssertEqual(message.valid, true)
            
            incompleteFieldExpectation.fulfill()
        }.store(in: &cancellables)
        
        completeField.insertText("123")
        incompleteField.insertText("12")
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testShouldThrowInvalidMask() throws {
        let textField = TextElementUITextField()
        let regexDigit = try! NSRegularExpression(pattern: "\\d")
        let invalidMaskLongString = ["abc", regexDigit] as [Any]
        let invalidMaskWrongType = [regexDigit, 2] as [Any]
        let optionsLongString = TextElementOptions(mask: invalidMaskLongString)
        let optionsWrongType = TextElementOptions(mask: invalidMaskWrongType)
        
        XCTAssertThrowsError(try textField.setConfig(options: optionsLongString)) { error in
            XCTAssertEqual(error as! ElementConfigError, ElementConfigError.invalidMask)
        }
        
        XCTAssertThrowsError(try textField.setConfig(options: optionsWrongType)) { error in
            XCTAssertEqual(error as! ElementConfigError, ElementConfigError.invalidMask)
        }
    }
    
    func testTransformTextField() throws {
        let textField = TextElementUITextField()
        let phoneNumber = "(123)456-7890"
        let transformedPhoneNumber = "1234567890"
        let transformPattern = "[()-]"
        let maskPattern = "\\d"
        let stringReplacement = ""
        textField.insertText(phoneNumber)

        let charactersToRemove = try! NSRegularExpression(pattern: transformPattern)
        let regexDigit = try! NSRegularExpression(pattern: maskPattern)
        let mask = [regexDigit, regexDigit, regexDigit]

        let options = TextElementOptions(mask: mask, transform: ElementTransform(matcher: charactersToRemove, stringReplacement: stringReplacement))

        try! textField.setConfig(options: options)

        let body: CreateToken = CreateToken(type: "token", data: [
                "textFieldRef": textField,
                "myProp": "myValue",
                "object": [
                    "nestedProp": "nestedValue",
                    "textFieldRef": textField,
                ]
        ])

        let apiKey = Configuration.getConfiguration().btApiKey!
        let transformExpectation = self.expectation(description: "Transform textfield")

        var createdToken: CreateTokenResponse? = nil
        BasisTheoryElements.basePath = "https://api-dev.basistheory.com"
        BasisTheoryElements.createToken(body: body, apiKey: apiKey) { data, error in
            createdToken = data

            XCTAssertNotNil(createdToken!.id)
            XCTAssertEqual(createdToken!.type!, "token")
            transformExpectation.fulfill()
        }

        waitForExpectations(timeout: 3, handler: nil)
        
        let transformQueryExpectation = self.expectation(description: "Query Token By ID to Test Transformed Textfield")
        let privateApiKey = Configuration.getConfiguration().privateBtApiKey!
        TokensAPI.getByIdWithRequestBuilder(id: createdToken!.id!).addHeader(name: "BT-API-KEY", value: privateApiKey).execute { result in
            do {
                let token = try result.get().body.data!.value as! [String: Any]

                XCTAssertEqual(token["textFieldRef"] as! String, transformedPhoneNumber)
                XCTAssertEqual(token["myProp"] as! String, "myValue")
                XCTAssertEqual((token["object"] as! [String: String])["nestedProp"], "nestedValue")
                XCTAssertEqual((token["object"] as! [String: String])["textFieldRef"], transformedPhoneNumber)

                transformQueryExpectation.fulfill()
            } catch {
                print(error)
            }
        }

        waitForExpectations(timeout: 3, handler: nil)
    }
}
