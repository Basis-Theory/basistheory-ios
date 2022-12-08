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
            XCTAssertEqual(message.valid, false)
            
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
            XCTAssertEqual(message.valid, true)
            
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
        let expirationDateTextField = CardExpirationDateUITextField()
        
        let expDateInputExpectation = self.expectation(description: "Expiration date input")
        let expDateDeleteExpectation = self.expectation(description: "Expiration date delete")
        var cancellables = Set<AnyCancellable>()
        expirationDateTextField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            XCTAssertEqual(message.type, "textChange")
            
            if (!message.empty) {
                XCTAssertEqual(message.valid, true)
                XCTAssertEqual(message.complete, true)
                expDateInputExpectation.fulfill()
            } else {
                XCTAssertEqual(message.valid, false)
                XCTAssertEqual(message.complete, false)
                expDateDeleteExpectation.fulfill()
            }
        }.store(in: &cancellables)
        
        let futureYear = getCurrentYear() + 1
        
        expirationDateTextField.insertText(String(getCurrentMonth()) + "/" + String(futureYear))
        expirationDateTextField.text = ""
        expirationDateTextField.insertText("")
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testExpirationDateSpecialtyMethods() throws {
        let expirationDateTextField = CardExpirationDateUITextField()
        let futureYear = getCurrentYear() + 1
        let formattedYear = "20" + String(futureYear)
        expirationDateTextField.text = String(getCurrentMonth()) + "/" + String(futureYear)
        
        let body: [String: Any] = [
            "data": [
                "monthRef": expirationDateTextField.month(),
                "yearRef": expirationDateTextField.year(),
            ],
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
                XCTAssertEqual(token["monthRef"] as! String, String(self.getCurrentMonth()))
                XCTAssertEqual(token["yearRef"] as! String, formattedYear)
                
                idQueryExpectation.fulfill()
            } catch {
                print(error)
            }
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testThrowsWithInvalidCardExpirationDateInput() {
        let expirationDateTextField = CardExpirationDateUITextField()
        let pastYear = getCurrentYear() - 2
        let invalidExpirationDate = String(getCurrentMonth()) + "/" + String(pastYear)
        expirationDateTextField.text = invalidExpirationDate
        
        let body: [String: Any] = [
            "data": [
                "monthRef": expirationDateTextField.month(),
                "yearRef": expirationDateTextField.year(),
            ],
            "type": "token"
        ]
        
        let publicApiKey = Configuration.getConfiguration().btApiKey!
        let tokenizeExpectation = self.expectation(description: "Throws before tokenize")
        BasisTheoryElements.basePath = "https://api-dev.basistheory.com"
        BasisTheoryElements.tokenize(body: body, apiKey: publicApiKey) { data, error in
            XCTAssertNil(data)
            XCTAssertEqual(error as? TokenizingError, TokenizingError.invalidInput)
            
            tokenizeExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 30, handler: nil)
    }
}
