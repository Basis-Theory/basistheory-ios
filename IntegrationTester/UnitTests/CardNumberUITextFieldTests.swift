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
            
            let eventDetails = message.details as [ElementEventDetails]
            let brandDetails = eventDetails[0]
            
            XCTAssertEqual(brandDetails.type, "cardBrand")
            XCTAssertEqual(brandDetails.message, "visa")
            
            // assert metadta
            XCTAssertEqual(cardNumberTextField.metadata.empty, false)
            XCTAssertEqual(cardNumberTextField.metadata.valid, false)
            XCTAssertEqual(cardNumberTextField.cardMetadata.cardBrand, "visa")
            
            if (!incompleteNumberExpectationHasBeenFulfilled) {
                XCTAssertEqual(message.complete, false) // mask incomplete and number is invalid
                XCTAssertEqual(eventDetails.count, 1)
                incompleteNumberExpectation.fulfill()
                incompleteNumberExpectationHasBeenFulfilled = true
            } else {
                XCTAssertEqual(message.complete, false) // mask completed but number invalid
                XCTAssertEqual(eventDetails.count, 1)
                
                luhnInvalidNumberExpectation.fulfill()
            }
        }.store(in: &cancellables)
        
        cardNumberTextField.insertText("4129")
        cardNumberTextField.text = ""
        cardNumberTextField.insertText("4129939187355598") // luhn invalid
        cardNumberTextField.text = ""
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testValidNumberAndEventDetails() throws {
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
            
            // assert metadata
            XCTAssertEqual(cardNumberTextField.metadata.empty, false)
            XCTAssertEqual(cardNumberTextField.metadata.valid, true)
            
            let eventDetails = message.details as [ElementEventDetails]
            let brandDetails = eventDetails[0]
            let last4Details = eventDetails[1]
            let binDetails = eventDetails[2]
            
            XCTAssertEqual(brandDetails.type, "cardBrand")
            XCTAssertEqual(last4Details.type, "cardLast4")
            XCTAssertEqual(binDetails.type, "cardBin")
            
            if (!visaExpectationHasBeenFulfilled) {
                XCTAssertEqual(message.complete, true)
                XCTAssertEqual(brandDetails.message, "visa")
                XCTAssertEqual(last4Details.message, "4242")
                XCTAssertEqual(binDetails.message, "42424242")
                
                // assert metadata
                XCTAssertEqual(cardNumberTextField.metadata.complete, true)
                XCTAssertEqual(cardNumberTextField.cardMetadata.cardBrand, "visa")
                XCTAssertEqual(cardNumberTextField.cardMetadata.cardLast4, "4242")
                XCTAssertEqual(cardNumberTextField.cardMetadata.cardBin, "42424242")
                
                validVisaCardNumberExpectation.fulfill()
                visaExpectationHasBeenFulfilled = true
            } else if (!mastercardExpectationHasBeenFulfilled) {
                XCTAssertEqual(message.complete, true)
                XCTAssertEqual(brandDetails.message, "mastercard")
                XCTAssertEqual(last4Details.message, "5717")
                XCTAssertEqual(binDetails.message, "54544229")
                
                // assert metadata
                XCTAssertEqual(cardNumberTextField.metadata.complete, true)
                XCTAssertEqual(cardNumberTextField.cardMetadata.cardBrand, "mastercard")
                XCTAssertEqual(cardNumberTextField.cardMetadata.cardLast4, "5717")
                XCTAssertEqual(cardNumberTextField.cardMetadata.cardBin, "54544229")
                validMasterCardNumberExpectation.fulfill()
                mastercardExpectationHasBeenFulfilled = true
            } else {
                XCTAssertEqual(message.complete, true)
                XCTAssertEqual(brandDetails.message, "americanExpress")
                XCTAssertEqual(last4Details.message, "8868")
                XCTAssertEqual(binDetails.message, "348570")
                
                // assert metadata
                XCTAssertEqual(cardNumberTextField.metadata.complete, true)
                XCTAssertEqual(cardNumberTextField.cardMetadata.cardBrand, "americanExpress")
                XCTAssertEqual(cardNumberTextField.cardMetadata.cardLast4, "8868")
                XCTAssertEqual(cardNumberTextField.cardMetadata.cardBin, "348570")
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
                
                // assert metadata
                XCTAssertEqual(cardNumberTextField.metadata.valid, true)
                XCTAssertEqual(cardNumberTextField.metadata.complete, true)
                numberInputExpectation.fulfill()
            } else {
                XCTAssertEqual(message.valid, false)
                XCTAssertEqual(message.complete, false)
                
                // assert metadata
                XCTAssertEqual(cardNumberTextField.metadata.valid, false)
                XCTAssertEqual(cardNumberTextField.metadata.complete, false)
                
                // card bin and last 4 should be nil for non-complete
                XCTAssertEqual(cardNumberTextField.cardMetadata.cardLast4, nil)
                XCTAssertEqual(cardNumberTextField.cardMetadata.cardBin, nil)
                numberDeleteExpectation.fulfill()
            }
        }.store(in: &cancellables)
        
        cardNumberTextField.insertText("4242424242424242")
        cardNumberTextField.text = ""
        cardNumberTextField.insertText("")
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testThrowsWithInvalidCardNumberInput() throws {
        let cardNumberTextField = CardNumberUITextField()
        let invalidCardNumber = "4129939187355598" //Luhn invalid
        cardNumberTextField.text = invalidCardNumber
        
        let body: [String: Any] = [
            "data": [
                "cardNumberRef": cardNumberTextField,
            ],
            "type": "card_number"
        ]
        
        let publicApiKey = Configuration.getConfiguration().btApiKey!
        let tokenizeExpectation = self.expectation(description: "Throws before tokenize")
        BasisTheoryElements.basePath = "https://api.flock-dev.com"
        BasisTheoryElements.tokenize(body: body, apiKey: publicApiKey) { data, error in
            XCTAssertNil(data)
            XCTAssertEqual(error as? TokenizingError, TokenizingError.invalidInput)
            
            tokenizeExpectation.fulfill()
        }
        
        let privateBtApiKey = Configuration.getConfiguration().privateBtApiKey!
        let proxyKey = Configuration.getConfiguration().proxyKey!
        let proxyExpectation = self.expectation(description: "Throws before proxy")
        let proxyHttpRequest = ProxyHttpRequest(method: .post, body: body)

        BasisTheoryElements.proxy(
            apiKey: privateBtApiKey,
            proxyKey: proxyKey,
            proxyHttpRequest: proxyHttpRequest)
        { response, data, error in
            XCTAssertNil(data)
            XCTAssertEqual(error as? ProxyError, ProxyError.invalidInput)
            
            proxyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 30, handler: nil)
        
    }
    
    func testEnableCopy() throws {
        let cardNumberTextField = CardNumberUITextField()
        try! cardNumberTextField.setConfig(options: TextElementOptions(enableCopy: true))
        
        let rightViewContainer = cardNumberTextField.rightView
        let iconImageView = rightViewContainer?.subviews.compactMap { $0 as? UIImageView }.first
        
        // assert icon exists
        XCTAssertNotNil(cardNumberTextField.rightView)
        XCTAssertNotNil(iconImageView)
    }
    
    func testCopyIconColor() throws {
        let cardNumberTextField = CardExpirationDateUITextField()
        try! cardNumberTextField.setConfig(options: TextElementOptions(enableCopy: true, copyIconColor: UIColor.red))
        
        let rightViewContainer = cardNumberTextField.rightView
        let iconImageView = rightViewContainer?.subviews.compactMap { $0 as? UIImageView }.first
        
        // assert icon exists
        XCTAssertNotNil(iconImageView)
        
        // assert color
        XCTAssertEqual(iconImageView?.tintColor, UIColor.red)
    }
}
