//
//  CardExpirationDateUITextField.swift
//  IntegrationTesterTests
//
//  Created by Lucas Chociay on 11/30/22.
//

import XCTest
import BasisTheoryElements
import BasisTheory
import Combine

final class CardExpirationDateUITextFieldTests: XCTestCase {
    override func setUpWithError() throws { }
    
    override func tearDownWithError() throws { }
    
    func getCurrentYear() -> Int {
        let now = Date()
        let dateFormatter = DateFormatter()
        
        // check year
        dateFormatter.dateFormat = "YY"
        let currentYear = Int(dateFormatter.string(from: now))!
        
        return currentYear
    }
    
    func getCurrentMonth() -> Int {
        let now = Date()
        let dateFormatter = DateFormatter()
        
        // check year
        dateFormatter.dateFormat = "MM"
        let currentMonth = Int(dateFormatter.string(from: now))!
        
        return currentMonth
    }
    
    func testInvalidExpirationDateEvents() throws {
        let expirationDateTextField = CardExpirationDateUITextField()
        
        let incompleteDateExpectation = self.expectation(description: "Incomplete expiration date")
        let invalidDateYearInThePastExpectation = self.expectation(description: "Invalid expiration date with year in the past")
        let invalidDateMonthInThePastExpectation = self.expectation(description: "Invalid expiration date with month in the past")
        
        var incompleteDateExpectationHasBeenFulfilled = false
        var invalidDateYearInThePastExpectationHasBeenFulfilled = false
        
        var cancellables = Set<AnyCancellable>()
        expirationDateTextField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            XCTAssertEqual(message.type, "textChange")
            XCTAssertEqual(message.empty, false)
            XCTAssertEqual(message.invalid, true)
            
            if (!incompleteDateExpectationHasBeenFulfilled) {
                XCTAssertEqual(message.complete, false)
                incompleteDateExpectation.fulfill()
                incompleteDateExpectationHasBeenFulfilled = true
            } else if (!invalidDateYearInThePastExpectationHasBeenFulfilled) {
                XCTAssertEqual(message.complete, false)
                invalidDateYearInThePastExpectation.fulfill()
                invalidDateYearInThePastExpectationHasBeenFulfilled = true
            } else {
                XCTAssertEqual(message.complete, false)
                invalidDateMonthInThePastExpectation.fulfill()
            }
        }.store(in: &cancellables)
        
        let pastYear = getCurrentYear() - 1
        let pastMonth = getCurrentMonth() - 1
        
        expirationDateTextField.insertText("1") // incomplete
        expirationDateTextField.text = ""
        expirationDateTextField.insertText("12/" + String(pastYear)) // year in the past
        expirationDateTextField.text = ""
        expirationDateTextField.insertText(String(pastMonth) + "/" + String(getCurrentYear())) // month in past
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testValidExpirationDateEvents() throws {
        let expirationDateTextField = CardExpirationDateUITextField()
        
        let validExpDateFutureYearExpectation = self.expectation(description: "Valid expiration date - future year")
        let validExpDateFutureMonthExpectation = self.expectation(description: "Valid expiration date - future month")
        let validExpDateCurrentMonthAndYear = self.expectation(description: "Valid expiration date - current month and year")
        
        var futureYearExpectationHasBeenFulfilled = false
        var futureMonthExpectationHasBeenFulfilled = false
        
        var cancellables = Set<AnyCancellable>()
        expirationDateTextField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            XCTAssertEqual(message.type, "textChange")
            XCTAssertEqual(message.empty, false)
            XCTAssertEqual(message.invalid, false)
            
            if (!futureYearExpectationHasBeenFulfilled) {
                XCTAssertEqual(message.complete, true)
                validExpDateFutureYearExpectation.fulfill()
                futureYearExpectationHasBeenFulfilled = true
            } else if (!futureMonthExpectationHasBeenFulfilled) {
                XCTAssertEqual(message.complete, true)
                validExpDateFutureMonthExpectation.fulfill()
                futureMonthExpectationHasBeenFulfilled = true
            } else {
                XCTAssertEqual(message.complete, true)
                validExpDateCurrentMonthAndYear.fulfill()
            }
        }.store(in: &cancellables)
        
        let futureYear = getCurrentYear() + 1
        let futureMonth = getCurrentMonth() + 1
        
        expirationDateTextField.insertText(String(getCurrentMonth()) + "/" + String(futureYear)) // future year
        expirationDateTextField.text = ""
        expirationDateTextField.insertText(String(futureMonth) + "/" + String(getCurrentYear())) // future month
        expirationDateTextField.text = ""
        expirationDateTextField.insertText(String(getCurrentMonth()) + "/" + String(getCurrentYear())) // current month/year
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWithAndWithoutExpirationDateInputEvents() throws {
        let cvcTextField = CardVerificationCodeElementUITextField()
        
        let cvcInputExpectation = self.expectation(description: "CVC input")
        let cvcDeleteExpectation = self.expectation(description: "CVC delete")
        var cancellables = Set<AnyCancellable>()
        cvcTextField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            XCTAssertEqual(message.type, "textChange")
            
            if (!message.empty) {
                XCTAssertEqual(message.invalid, false)
                XCTAssertEqual(message.complete, true)
                cvcInputExpectation.fulfill()
            } else {
                XCTAssertEqual(message.invalid, true)
                XCTAssertEqual(message.complete, false)
                cvcDeleteExpectation.fulfill()
            }
        }.store(in: &cancellables)
        
        cvcTextField.insertText("123")
        cvcTextField.text = ""
        cvcTextField.insertText("")
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // TODO: test month() and year() methods
}
