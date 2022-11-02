//
//  IntegrationTesterUITests.swift
//  IntegrationTesterUITests
//
//  Created by Brian Gonzalez on 10/18/22.
//

import XCTest
import AnyCodable
import BasisTheory

final class IntegrationTesterUITests: XCTestCase {
    private var app: XCUIApplication = XCUIApplication()

    override func setUpWithError() throws {
        app.launch()
    }

    override func tearDownWithError() throws { }
    
    /*
     acceptance tests. that you can
     3. set styles
     4. subscribe to events
     */
    
    func testTextSetter() throws {
        let setTextButton = app.buttons["Set Text"]
        setTextButton.press(forDuration: 0.1)
        
        let nameTextField = app.textFields["Name"]
        let phoneNumberTextField = app.textFields["Phone Number"]
        
        XCTAssertEqual(nameTextField.value as! String, "Tom Cruise")
        XCTAssertEqual(phoneNumberTextField.value as! String, "555-123-4567")
    }
    
    func testTokenizingWithTextElements() throws {
        let setTextButton = app.buttons["Set Text"]
        setTextButton.press(forDuration: 0.1)
        
        let tokenizeButton = app.buttons["Tokenize"]
        tokenizeButton.press(forDuration: 0.1)

        wait {
            let outputLabel = self.app.textViews["Output"]
            let createdToken = convertStringToDictionary(text: (outputLabel.value as! String))

            XCTAssertNotNil(createdToken!["id"])
            XCTAssertEqual(createdToken!["type"] as! String, "token")
            
            let idQueryExpectation = self.expectation(description: "Token ID Query")

            BasisTheoryAPI.basePath = "https://api-dev.basistheory.com"
            let config = Configuration.getConfiguration()
            TokensAPI.getByIdWithRequestBuilder(id: createdToken!["id"] as! String).addHeader(name: "BT-API-KEY", value: config.btApiKey!).execute { result in
                let token = try! result.get().body.data!.value as! [String: Any]

                XCTAssertEqual(token["name"] as! String, "Tom Cruise")
                XCTAssertEqual(token["phoneNumber"] as! String, "555-123-4567")
                XCTAssertEqual(token["myProp"] as! String, "myValue")
                XCTAssertEqual((token["object"] as! [String: String])["nestedProp"], "nestedValue")
                XCTAssertEqual((token["object"] as! [String: String])["phoneNumber"], "555-123-4567")

                idQueryExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }

    func testExample() throws {
        let expectedText = "Drewsue Webuino"
        let nameTextField = app.textFields["Name"]
        nameTextField.tap()
        nameTextField.typeText(expectedText)
        XCTAssertEqual(nameTextField.value as! String, expectedText)
    }

    // re-evaluate if we need this
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
