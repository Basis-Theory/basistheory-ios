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
            XCTAssertEqual(message.invalid, false)

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
            XCTAssertEqual(message.invalid, false)
            
            completeFieldExpectation.fulfill()
        }.store(in: &cancellables)
        
        incompleteField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            XCTAssertEqual(message.type, "textChange")
            XCTAssertEqual(message.complete, false)
            XCTAssertEqual(message.invalid, false)
            
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
}
