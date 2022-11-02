//
//  IntegrationTesterTests.swift
//  IntegrationTesterTests
//
//  Created by Brian Gonzalez on 10/18/22.
//

import XCTest
import BasisTheoryElements

final class TextElementUITextFieldTests: XCTestCase {

    override func setUpWithError() throws { }

    override func tearDownWithError() throws { }

    func testNilReturnFromText() throws {
        let textField = TextElementUITextField()
        textField.text = "Drewsue Webuino"
        
        XCTAssertNil(textField.text)
    }
}
