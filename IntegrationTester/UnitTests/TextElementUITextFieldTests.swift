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
            
            // assert metadata updated
            XCTAssertEqual(nameTextField.metadata.complete, message.complete)
            XCTAssertEqual(nameTextField.metadata.valid, message.valid)

            if (!message.empty) {
                XCTAssertEqual(nameTextField.metadata.empty, false)
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
    
    func testFocusAndBlurEvent() throws {
        let field = TextElementUITextField()
        
        let focusExpectation = self.expectation(description: "Field focus")
        let blurExpectation = self.expectation(description: "Field blur")
        var focusExpectationFulfilled = false
        var cancellables = Set<AnyCancellable>()
        
        field.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            if (!focusExpectationFulfilled) {
                XCTAssertEqual(message.type, "focus")
                focusExpectationFulfilled = true
                focusExpectation.fulfill()
            } else {
                XCTAssertEqual(message.type, "blur")
                blurExpectation.fulfill()
            }
        }.store(in: &cancellables)
        
        field.sendActions(for: .editingDidBegin)
        field.sendActions(for: .editingDidEnd)
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testCompletionEventWithMask() throws {
        let completeField = TextElementUITextField()
        let incompleteField = TextElementUITextField()
        let regexDigit = try! NSRegularExpression(pattern: "\\d")
        let mask = [regexDigit, regexDigit, regexDigit]
        let options = TextElementOptions(mask: mask)
        
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
            XCTAssertEqual(message.maskSatisfied, true)
            XCTAssertEqual(message.valid, true)
            
            // assert metadata updated
            XCTAssertEqual(completeField.metadata.complete, message.complete)
            XCTAssertEqual(completeField.metadata.valid, message.valid)
            XCTAssertEqual(completeField.metadata.maskSatisfied, message.maskSatisfied)
            
            completeFieldExpectation.fulfill()
        }.store(in: &cancellables)
        
        incompleteField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            XCTAssertEqual(message.type, "textChange")
            XCTAssertEqual(message.complete, false)
            XCTAssertEqual(message.maskSatisfied, false)
            XCTAssertEqual(message.valid, true)
            
            // assert metadata updated
            XCTAssertEqual(incompleteField.metadata.complete, message.complete)
            XCTAssertEqual(incompleteField.metadata.valid, message.valid)
            XCTAssertEqual(incompleteField.metadata.maskSatisfied, message.maskSatisfied)
            
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
        BasisTheoryElements.basePath = "https://api.flock-dev.com"
        BasisTheoryElements.createToken(body: body, apiKey: apiKey) { data, error in
            createdToken = data

            XCTAssertNotNil(createdToken!.id)
            XCTAssertEqual(createdToken!.type!, "token")
            transformExpectation.fulfill()
        }

        waitForExpectations(timeout: 3)
        
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

        waitForExpectations(timeout: 3)
    }
    
    func testReadOnlyWhenValueRef() throws {
        let textField = TextElementUITextField()
        let readOnlyField = TextElementUITextField()
        
        readOnlyField.setValueRef(element: textField)
        
        XCTAssertEqual(readOnlyField.isFirstResponder, false)
        XCTAssertEqual(readOnlyField.becomeFirstResponder(), false)
    }
    
    func testCustomRegexValidation() throws {
        let textField = TextElementUITextField()
        let customPasswordRegex = try! NSRegularExpression(pattern: "^[A-Z]{5}_[A-Z0-9]{4}([0-9]{3})?$")
        
        try! textField.setConfig(options: TextElementOptions(validation: customPasswordRegex))
        
        textField.insertText("password!")
        
        XCTAssertFalse(textField.metadata.valid)
        
        textField.text = ""
        textField.insertText("DAFFY_DUCK500")
        
        XCTAssertTrue(textField.metadata.valid)
        
        try! textField.setConfig(options: TextElementOptions(validation: nil))
        
        textField.text = ""
        textField.insertText("password!")
        
        XCTAssertTrue(textField.metadata.valid)
    }
    
    func testIncompleteWhenCleared() throws {
        let textField = TextElementUITextField()
        var cancellables = Set<AnyCancellable>()
        
        textField.insertText("a")
        XCTAssertTrue(textField.metadata.complete)
        
        textField.text = ""
        
        textField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            XCTAssertEqual(message.type, "textChange")
            XCTAssertEqual(message.complete, true)
            XCTAssertEqual(message.maskSatisfied, true)
            XCTAssertEqual(message.empty, true)
        }.store(in: &cancellables)
        
        XCTAssertTrue(textField.metadata.empty)
    }
    
    func testEnableCopy() throws {
        let textField = TextElementUITextField()
        try! textField.setConfig(options: TextElementOptions(enableCopy: true))
        
        let rightViewContainer = textField.rightView
        let iconImageView = rightViewContainer?.subviews.compactMap { $0 as? UIImageView }.first
        
        // assert icon exists
        XCTAssertNotNil(textField.rightView)
        XCTAssertNotNil(iconImageView)
    }
    
    func testCopyIconColor() throws {
        let textField = TextElementUITextField()
        try! textField.setConfig(options: TextElementOptions(enableCopy: true, copyIconColor: UIColor.red))
        
        let rightViewContainer = textField.rightView
        let iconImageView = rightViewContainer?.subviews.compactMap { $0 as? UIImageView }.first
        
        // assert icon exists
        XCTAssertNotNil(iconImageView)
        
        // assert color
        XCTAssertEqual(iconImageView?.tintColor, UIColor.red)
    }
}
