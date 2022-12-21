//
//  SplitCardElementsUITextFieldTests.swift
//  AcceptanceTests
//
//  Created by Amber Torres on 12/20/22.
//

import XCTest

final class SplitCardElementsIntegrationTesterUITests: XCTestCase {
    private var app: XCUIApplication = XCUIApplication()

    override func setUpWithError() throws {
        app.launch()
        
        let textElementExampleButton = app.buttons["Split Card Elements Example"]
        textElementExampleButton.press(forDuration: 0.1)
    }
    
    override func tearDownWithError() throws { }
    
    func testTextSetter() throws {
        //TO-DO
    }
    
    func testCardNumberMaskIsAppropriateForCardBrand() throws {
        let validVisaCardNumber = "4242424242424242"
        let invalidVisaCardNumbers = ["424242424242424a"
        
        let cardNumberTextField = app.textFields["Card Number"]
        cardNumberTextField.tap()
        
        cardNumberTextField.typeText(visaCardNumber)
        XCTAssertEqual(cardNumberTextField.value as! String, "4242 4242 4242 4242")
        
        cardNumberTextField.doubleTap()
        app.keys["delete"].tap()
        
        
    }
    
    func testCVCIsAppropriateForCardBrand() throws {
        //TODO
    }
}
