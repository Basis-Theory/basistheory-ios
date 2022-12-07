//
//  CardNumberUITextFieldTests.swift
//  IntegrationTesterTests
//
//  Created by Lucas Chociay on 12/05/22.
//

import XCTest
import BasisTheoryElements
import BasisTheory
import Combine

final class CardNumberUITextFieldTests: XCTestCase {
    override func setUpWithError() throws { }
    override func tearDownWithError() throws { }
    
    func testInvalidCardNumberEvents() throws {
        let cardNumberTextField = CardNumberUITextField()
        
        let incompleteNumberExpectation = self.expectation(description: "Incomplete card number")
        let luhnInvalidNumberExpectation = self.expectation(description: "Luhn invalid card")
        
        var incompleteNumberExpectationHasBeenFulfilled = false
        
        var cancellables = Set<AnyCancellable>()
        cardNumberTextField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            XCTAssertEqual(message.type, "textChange")
            XCTAssertEqual(message.empty, false)
            XCTAssertEqual(message.valid, false)
            
            if (!incompleteNumberExpectationHasBeenFulfilled) {
                XCTAssertEqual(message.complete, false)
                incompleteNumberExpectation.fulfill()
                incompleteNumberExpectationHasBeenFulfilled = true
            } else {
                XCTAssertEqual(message.complete, true) // mask completed but number invalid
                luhnInvalidNumberExpectation.fulfill()
            }
        }.store(in: &cancellables)
        
        cardNumberTextField.insertText("4129")
        cardNumberTextField.text = ""
        cardNumberTextField.insertText("4129939187355598") // luhn invalid
        cardNumberTextField.text = ""
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testValidNumberAndBrandEvents() throws {
        let cardNumberTextField = CardNumberUITextField()
        
        let validVisaCardNumberExpectation = self.expectation(description: "Valid visa card number")
        let validMasterCardNumberExpectation = self.expectation(description: "Valid mastercard card number")
        let validAmexCardNumberExpectation = self.expectation(description: "Valid amex card number")
        
        var visaExpectationHasBeenFulfilled = false
        var mastercardExpectationHasBeenFulfilled = false
        
        var cancellables = Set<AnyCancellable>()
        cardNumberTextField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            XCTAssertEqual(message.type, "textChange")
            XCTAssertEqual(message.empty, false)
            XCTAssertEqual(message.valid, true)
            let brandDetails = message.details[0] as ElementEventDetails
            XCTAssertEqual(brandDetails.type, "cardBrand")
            
            if (!visaExpectationHasBeenFulfilled) {
                XCTAssertEqual(message.complete, true)
                XCTAssertEqual(brandDetails.message, "visa")
                validVisaCardNumberExpectation.fulfill()
                visaExpectationHasBeenFulfilled = true
            } else if (!mastercardExpectationHasBeenFulfilled) {
                XCTAssertEqual(message.complete, true)
                XCTAssertEqual(brandDetails.message, "mastercard")
                validMasterCardNumberExpectation.fulfill()
                mastercardExpectationHasBeenFulfilled = true
            } else {
                XCTAssertEqual(message.complete, true)
                XCTAssertEqual(brandDetails.message, "americanExpress")
                validAmexCardNumberExpectation.fulfill()
            }
        }.store(in: &cancellables)
        
        cardNumberTextField.insertText("4242424242424242")
        cardNumberTextField.text = ""
        cardNumberTextField.insertText("5454422955385717")
        cardNumberTextField.text = ""
        cardNumberTextField.insertText("348570250878868")
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWithAndWithoutCardNumberInputEvents() throws {
        let cardNumberTextField = CardNumberUITextField()
        
        let numberInputExpectation = self.expectation(description: "Card number input")
        let numberDeleteExpectation = self.expectation(description: "Card number delete")
        var cancellables = Set<AnyCancellable>()
        cardNumberTextField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            XCTAssertEqual(message.type, "textChange")
            
            if (!message.empty) {
                XCTAssertEqual(message.valid, true)
                XCTAssertEqual(message.complete, true)
                numberInputExpectation.fulfill()
            } else {
                XCTAssertEqual(message.valid, false)
                XCTAssertEqual(message.complete, false)
                numberDeleteExpectation.fulfill()
            }
        }.store(in: &cancellables)
        
        cardNumberTextField.insertText("4242424242424242")
        cardNumberTextField.text = ""
        cardNumberTextField.insertText("")
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
