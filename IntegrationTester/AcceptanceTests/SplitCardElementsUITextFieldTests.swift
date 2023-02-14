//
//  SplitCardElementsIntegrationTesterUITests.swift
//  AcceptanceTests
//
//  Created by Amber Torres on 12/20/22.
//

import Foundation

import XCTest
import BasisTheoryElements
import Combine

final class SplitCardElementsIntegrationTesterUITests: XCTestCase {
    private var app: XCUIApplication = XCUIApplication()
    
    override func setUpWithError() throws {
        app.launch()
        
        let textElementExampleButton = app.buttons["Split Card Elements Example"]
        textElementExampleButton.press(forDuration: 0.1)
    }
    
    override func tearDownWithError() throws { }
    
    func testTextSetter() throws {
        let setTextButton = app.buttons["Set Text"]
        setTextButton.press(forDuration: 0.1)
        
        let cardNumberTextField = app.textFields["Card Number"]
        let expirationDateTextField = app.textFields["MM/YY"]
        let cvcTextField = app.textFields["CVC"]
        
        XCTAssertEqual(cardNumberTextField.value as! String, "4242 4242 4242 4242")
        XCTAssertEqual(expirationDateTextField.value as! String, "10/26")
        XCTAssertEqual(cvcTextField.value as! String, "909")
    }
    
    
    func testCardNumberMaskForVisaToAmericanExpress() throws {
        let validVisaCardNumber = "4242424242424242"
        let invalidVisaCardNumber = "42424242424242xx"
        
        let validAmericanExpressCardNumber = "348570250878868"
        let invalidAmericanExpressCardNumber = "34xx70250878868"
        
        let visaValidCVC = "432"
        let visaInvalidCVC = "4321"
        
        let americanExpressValidCVC = "1234"
        let americanExpressInvalidCVC = "12345"
        
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        
        cardNumberTextField.typeText(validVisaCardNumber)
        XCTAssertEqual(cardNumberTextField.value as! String, "4242 4242 4242 4242")
        
        let visaCardBrandResults = CardBrand.getCardBrand(text: validVisaCardNumber)
        XCTAssertEqual(visaCardBrandResults.bestMatchCardBrand!.cardBrandName, CardBrand.CardBrandName.visa)
        
        cardNumberTextField.doubleTap()
        
        cardNumberTextField.typeText(invalidVisaCardNumber)
        XCTAssertEqual(cardNumberTextField.value as! String, "4242 4242 4242 42")
        
        let invalidVisaCardBrandResults = CardBrand.getCardBrand(text: invalidVisaCardNumber)
        XCTAssertEqual(invalidVisaCardBrandResults.bestMatchCardBrand!.cardBrandName, CardBrand.CardBrandName.visa)
        
        try testVisaCVC()
        
        // Change the card from visa to amex to ensure brand change is detected and the mask updates accordingly
        
        cardNumberTextField.doubleTap()
        
        cardNumberTextField.typeText(validAmericanExpressCardNumber)
        XCTAssertEqual(cardNumberTextField.value as! String, "3485 702508 78868")
        
        let cardBrandResults = CardBrand.getCardBrand(text: validAmericanExpressCardNumber)
        XCTAssertEqual(cardBrandResults.bestMatchCardBrand!.cardBrandName, CardBrand.CardBrandName.americanExpress)
        
        cardNumberTextField.doubleTap()
        
        cardNumberTextField.typeText(invalidAmericanExpressCardNumber)
        XCTAssertEqual(cardNumberTextField.value as! String, "3470 250878 868")
        
        try testAmericanExpressCVC()
        
        func testVisaCVC() throws {
            
            let cvcTextField = app.textFields["CVC"]
            cvcTextField.tap()
            
            cvcTextField.typeText(visaValidCVC)
            XCTAssertEqual(cvcTextField.value as! String, "432")
            
            cvcTextField.doubleTap()
            
            cvcTextField.typeText(visaInvalidCVC)
            XCTAssertEqual(cvcTextField.value as! String, "432")
        }
        
        func testAmericanExpressCVC() throws {
            
            let cvcTextField = app.textFields["CVC"]
            cvcTextField.doubleTap()
            
            cvcTextField.typeText(americanExpressValidCVC)
            XCTAssertEqual(cvcTextField.value as! String, "1234")
            
            cvcTextField.doubleTap()
            
            cvcTextField.typeText(americanExpressInvalidCVC)
            XCTAssertEqual(cvcTextField.value as! String, "1234")
        }
    }
    
    func testCvcInputDoesNotChangeWithoutUserActionWhenCardBrandChanges() throws {
        let amExCardNumber = "378282246310005"
        
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText(amExCardNumber)
        
        let amExCvc = "4321"
        
        let cvcTextField = app.textFields["CVC"]
        cvcTextField.tap()
        cvcTextField.typeText(amExCvc)
        
        XCTAssertEqual(cvcTextField.value as! String, amExCvc)
        
        let visaCardNumber = "4242424242424242"
        
        cardNumberTextField.doubleTap()
        cardNumberTextField.typeText(visaCardNumber)
        
        XCTAssertEqual(cvcTextField.value as! String, amExCvc) // CVC value doesn't change even though new mask is applied
        
        cvcTextField.tap()
        cvcTextField.typeText("5") // user tries to type in 5
        
        XCTAssertEqual(cvcTextField.value as! String, "432") // mask is applied and truncates input after user action
    }
    
    func testMaskedElementSetValueRef() throws {
        let cardNumberTextField = app.textFields["Card Number"]
        let readOnlyTextField = app.textFields["Read Only"]
        
        cardNumberTextField.tap()
        cardNumberTextField.typeText("4242424242")
        
        XCTAssertEqual(readOnlyTextField.value as! String, "4242 4242 42")
    }
}
