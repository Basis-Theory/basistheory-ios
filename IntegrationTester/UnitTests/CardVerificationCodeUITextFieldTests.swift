//
//  CardVerificationCodeUITextField.swift
//  IntegrationTesterTests
//
//  Created by Brian Gonzalez on 10/18/22.
//

import XCTest
import BasisTheoryElements
import BasisTheory
import Combine

final class CardVerificationCodeUITextFieldTests: XCTestCase {
    override func setUpWithError() throws { }

    override func tearDownWithError() throws { }
    
    func testInvalidCVCEvents() throws {
        let cvcTextField = CardVerificationCodeElementUITextField()
        
        let invalidCvcWithLettersExpectation = self.expectation(description: "Invalid CVC with letters")
        let invalidCvcWith2DigitsExpectation = self.expectation(description: "Invalid CVC with 2 digits")
        let invalidCvcWith5DigitsExpectation = self.expectation(description: "Invalid CVC with 5 digits")
        
        var invalidCvcWithLettersExpectationHasBeenFulfilled = false
        var invalidCvcWith2DigitsExpectationHasBeenFulfilled = false

        var cancellables = Set<AnyCancellable>()
        cvcTextField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            XCTAssertEqual(message.type, "textChange")
            XCTAssertEqual(message.empty, false)
            XCTAssertEqual(message.valid, false)
            
            if (!invalidCvcWithLettersExpectationHasBeenFulfilled) {
                XCTAssertEqual(message.complete, false)
                invalidCvcWithLettersExpectation.fulfill()
                invalidCvcWithLettersExpectationHasBeenFulfilled = true
            } else if (!invalidCvcWith2DigitsExpectationHasBeenFulfilled) {
                XCTAssertEqual(message.complete, false)
                invalidCvcWith2DigitsExpectation.fulfill()
                invalidCvcWith2DigitsExpectationHasBeenFulfilled = true
            } else {
                XCTAssertEqual(message.complete, false)
                invalidCvcWith5DigitsExpectation.fulfill()
            }
        }.store(in: &cancellables)

        cvcTextField.insertText("badcvc")
        cvcTextField.text = ""
        cvcTextField.insertText("12")
        cvcTextField.insertText("345")
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testValidCVCEvents() throws {
        let cvcTextField = CardVerificationCodeElementUITextField()

        let valid3DigitCvcExpectation = self.expectation(description: "Valid 3-digit CVC")
        let valid4DigitCvcExpectation = self.expectation(description: "Valid 4-digit CVC")
        
        var threeDigitExpectationHasBeenFulfilled = false

        var cancellables = Set<AnyCancellable>()
        cvcTextField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            XCTAssertEqual(message.type, "textChange")
            XCTAssertEqual(message.empty, false)
            XCTAssertEqual(message.valid, true)
            
            if (!threeDigitExpectationHasBeenFulfilled) {
                XCTAssertEqual(message.complete, true)
                valid3DigitCvcExpectation.fulfill()
                threeDigitExpectationHasBeenFulfilled = true
            } else {
                XCTAssertEqual(message.complete, true)
                valid4DigitCvcExpectation.fulfill()
            }
        }.store(in: &cancellables)

        cvcTextField.insertText("123")
        cvcTextField.insertText("4")
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWithAndWithoutCVCInputEvents() throws {
        let cvcTextField = CardVerificationCodeElementUITextField()
        
        let cvcInputExpectation = self.expectation(description: "CVC input")
        let cvcDeleteExpectation = self.expectation(description: "CVC delete")
        var cancellables = Set<AnyCancellable>()
        cvcTextField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            XCTAssertEqual(message.type, "textChange")
            
            if (!message.empty) {
                XCTAssertEqual(message.valid, true)
                XCTAssertEqual(message.complete, true)
                cvcInputExpectation.fulfill()
            } else {
                XCTAssertEqual(message.valid, false)
                XCTAssertEqual(message.complete, false)
                cvcDeleteExpectation.fulfill()
            }
        }.store(in: &cancellables)

        cvcTextField.insertText("123")
        cvcTextField.text = ""
        cvcTextField.insertText("")
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
