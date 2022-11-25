//
//  IntegrationTesterUITests.swift
//  IntegrationTesterUITests
//
//  Created by Brian Gonzalez on 10/18/22.
//

import XCTest

final class IntegrationTesterUITests: XCTestCase {
    private var app: XCUIApplication = XCUIApplication()

    override func setUpWithError() throws {
        app.launch()

        let textElementExampleButton = app.buttons["TextElementUITextField Example"]
        textElementExampleButton.press(forDuration: 0.1)
    }

    override func tearDownWithError() throws { }
    
    func testTextSetter() throws {
        let setTextButton = app.buttons["Set Text"]
        setTextButton.press(forDuration: 0.1)
        
        let nameTextField = app.textFields["Name"]
        let phoneNumberTextField = app.textFields["Phone Number"]
        
        XCTAssertEqual(nameTextField.value as! String, "Tom Cruise")
        XCTAssertEqual(phoneNumberTextField.value as! String, "555-123-4567")
    }
}
