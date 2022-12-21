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
    
    
    func testCardNumberMaskForVisaAndMastercard() throws {
        let validVisaCardNumber = "4242424242424242"
        let invalidVisaCardNumber = "42424242424242aa"
        
        let validMastercardCardNumber = "5151515151515151"
        let invalidMastercardCardNumber = "51515151515151aa"
        
        let validCVC = "123"
        let invalidCVC = "1234"
        
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
        
        try testCVC()
        
        // Change the card brand from visa mastercard to ensure brand change is detected and the mask updates
        
        cardNumberTextField.doubleTap()

        cardNumberTextField.typeText(validMastercardCardNumber)
        XCTAssertEqual(cardNumberTextField.value as! String, "5151 5151 5151 5151")

        let mastercardCardBrandResults = CardBrand.getCardBrand(text: validMastercardCardNumber)
        XCTAssertEqual(mastercardCardBrandResults.bestMatchCardBrand!.cardBrandName, CardBrand.CardBrandName.mastercard)
        
        cardNumberTextField.doubleTap()
        
        cardNumberTextField.typeText(invalidMastercardCardNumber)
        XCTAssertEqual(cardNumberTextField.value as! String, "5151 5151 5151 51")
        
        let invalidMasterCardBrandResults = CardBrand.getCardBrand(text: invalidMastercardCardNumber)
        XCTAssertEqual(invalidMasterCardBrandResults.bestMatchCardBrand!.cardBrandName, CardBrand.CardBrandName.mastercard)
        
        try testCVC()
        
        func testCVC() throws {
            
            let cvcTextField = app.textFields["CVC"]
            cvcTextField.tap()
            
            cvcTextField.typeText(validCVC)
            XCTAssertEqual(cvcTextField.value as! String, "123")
            
            cvcTextField.doubleTap()
            
            cvcTextField.typeText(invalidCVC)
            XCTAssertEqual(cvcTextField.value as! String, "123")
        }
        
        // To-do: Investigate how to make more concise
        
    }
    
    func testCardNumberAndCVCMaskForAmericanExpress() throws {
        let validAmericanExpressCardNumber = "348570250878868"
        let invalidAmericanExpressCardNumber = "34aa70250878868"
        let validCVC = "1234"
        let invalidCVC = "123"

        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()

        cardNumberTextField.typeText(validAmericanExpressCardNumber)
        XCTAssertEqual(cardNumberTextField.value as! String, "3485 702508 78868")
        
        let cardBrandResults = CardBrand.getCardBrand(text: validAmericanExpressCardNumber)
        XCTAssertEqual(cardBrandResults.bestMatchCardBrand!.cardBrandName, CardBrand.CardBrandName.americanExpress)
        
        cardNumberTextField.doubleTap()

        cardNumberTextField.typeText(invalidAmericanExpressCardNumber)
        XCTAssertEqual(cardNumberTextField.value as! String, "3470 250878 868")
        
        let cvcTextField = app.textFields["CVC"]
        cvcTextField.tap()
        
        cvcTextField.typeText(validCVC)
        XCTAssertEqual(cvcTextField.value as! String, "1234")
        
        cvcTextField.doubleTap()
        
        cvcTextField.typeText(invalidCVC)
        XCTAssertEqual(cvcTextField.value as! String, "123")
        
    }

    //to-do: diners club, 

    //to-do: discover, jcb, union pay, maestro, elo, mir, hiper, hipercard are same as visa and mastercard in terms of cvc length and gaps
}
