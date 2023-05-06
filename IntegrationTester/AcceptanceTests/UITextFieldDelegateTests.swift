//
//  UITextFieldDelegateTests.swift
//  AcceptanceTests
//
//  Created by Brian Gonzalez on 5/5/23.
//

import XCTest

final class UITextFieldDelegateTests: XCTestCase {
    private var app: XCUIApplication = XCUIApplication()
    
    override func setUpWithError() throws {
        app.launch()
    }
    
    override func tearDownWithError() throws { }
    
    func testNotUsingBasisTheoryUIViewControllerClass() throws {
        let failingDelegateExampleButton = app.buttons["Failing Delegate Example"]
        failingDelegateExampleButton.press(forDuration: 0.1)
        
        let nameTextField = app.textFields["Name"]
        nameTextField.tap()
        nameTextField.typeText("Drewsue")
        
        app.keyboards.buttons["return"].tap()
        
        XCTAssertTrue(app.switches["successSwitch"].value as? String == "0")
    }
    
    func testUsingBasisTheoryUIViewControllerClass() throws {
        let failingDelegateExampleButton = app.buttons["Succeeding Delegate Example"]
        failingDelegateExampleButton.press(forDuration: 0.1)
        
        let nameTextField = app.textFields["Name"]
        nameTextField.tap()
        nameTextField.typeText("Drewsue")
        
        app.keyboards.buttons["return"].tap()
        
        XCTAssertTrue(app.switches["successSwitch"].value as? String == "1")
    }
}
