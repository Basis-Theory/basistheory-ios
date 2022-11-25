//
//  TextElementUITextFieldTests.swift
//  IntegrationTesterTests
//
//  Created by Brian Gonzalez on 10/18/22.
//

import XCTest
import BasisTheoryElements
import BasisTheory
import Combine

final class TextElementUITextFieldTests: XCTestCase {
    override func setUpWithError() throws { }

    override func tearDownWithError() throws { }
    
    func testEventsWithAndWithoutText() throws {
        let nameTextField = TextElementUITextField()
        
        let nameInputExpectation = self.expectation(description: "Name input")
        let nameDeleteExpectation = self.expectation(description: "Name delete")
        var cancellables = Set<AnyCancellable>()
        nameTextField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            XCTAssertEqual(message.type, "textChange")
            XCTAssertEqual(message.complete, true)
            XCTAssertEqual(message.invalid, false)

            if (!message.empty) {
                nameInputExpectation.fulfill()
            } else {
                nameDeleteExpectation.fulfill()
            }
        }.store(in: &cancellables)

        nameTextField.insertText("Drewsue Webuino")
        nameTextField.text = ""
        nameTextField.insertText("")
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
