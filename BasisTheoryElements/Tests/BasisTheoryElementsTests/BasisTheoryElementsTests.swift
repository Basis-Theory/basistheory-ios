import XCTest
@testable import BasisTheoryElements

final class BasisTheoryElementsTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        let textElementUITextField = TextElementUITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        
        textElementUITextField.text = "Drewsue Webuino"

         XCTAssertEqual(textElementUITextField.text, nil)
    }
}
