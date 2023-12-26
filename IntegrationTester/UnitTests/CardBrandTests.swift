//
//  CardBrandTests.swift
//  UnitTests
//
//  Created by Brian Gonzalez on 12/1/22.
//

import Foundation

import XCTest
import BasisTheoryElements
import Combine

final class CardBrandTests: XCTestCase {
    override func setUpWithError() throws { }
    override func tearDownWithError() throws {
        // Reset card brands for subsequent tests
        CardBrand.addCardBrands(cardBrands: CardBrand.DefaultCardBrands)
    }
    
    func testBestMatchAndMatchingCardBrandsReturned() throws {
        let regexDigit = try! NSRegularExpression(pattern: "\\d")
        let threeDigitCvc = [regexDigit, regexDigit, regexDigit]
        let cardBrandResults = CardBrand.getCardBrand(text: "650032")
        
        XCTAssertFalse(cardBrandResults.maskSatisfied)
        
        XCTAssertEqual(cardBrandResults.bestMatchCardBrand!.cardBrandName, CardBrandName.elo)
        XCTAssertEqual(cardBrandResults.bestMatchCardBrand!.cvcMaskInput, threeDigitCvc)
        XCTAssertEqual(cardBrandResults.bestMatchCardBrand!.validLengths, [16])
        XCTAssertEqual(cardBrandResults.bestMatchCardBrand!.cardNumberMaskInput.count, 19)
        
        XCTAssertEqual(cardBrandResults.matchingCardBrands[0].cardBrandName, CardBrandName.discover)
        XCTAssertEqual(cardBrandResults.matchingCardBrands[0].cvcMaskInput, threeDigitCvc)
        XCTAssertEqual(cardBrandResults.matchingCardBrands[0].validLengths, [16, 19])
        XCTAssertEqual(cardBrandResults.matchingCardBrands[0].cardNumberMaskInput.count, 22)
        
        for i in 0...4 {
            if i == 4 {
                XCTAssertEqual(cardBrandResults.bestMatchCardBrand!.cardNumberMaskInput[i] as! String, " ")
                XCTAssertEqual(cardBrandResults.matchingCardBrands[0].cardNumberMaskInput[i] as! String, " ")
            } else {
                XCTAssertEqual(cardBrandResults.bestMatchCardBrand!.cardNumberMaskInput[i] as! NSRegularExpression, regexDigit)
                XCTAssertEqual(cardBrandResults.matchingCardBrands[0].cardNumberMaskInput[i] as! NSRegularExpression, regexDigit)
            }
        }
    }
    
    func testCustomBinValidation() throws {
        let customCardBrands =  [CardBrandDetails(cardBrandName: "customVisaWithTabapayCards", cardIdentifiers: [4, 8405], cvcMaskInput: [try! NSRegularExpression(pattern: "\\d"), try! NSRegularExpression(pattern: "\\d"), try! NSRegularExpression(pattern: "\\d")], gaps: [4, 8, 12], validLengths: [16, 18, 19])]
        CardBrand.addCardBrands(cardBrands: customCardBrands)
        
        
        let mastercardResults = CardBrand.getCardBrand(text: "5555555555554444")
        
        XCTAssertFalse(mastercardResults.maskSatisfied)
        XCTAssertNil(mastercardResults.bestMatchCardBrand)
        XCTAssertEqual(mastercardResults.matchingCardBrands.count, 0)
        
        
        let customBinResults = CardBrand.getCardBrand(text: "8405124124999998")
        
        XCTAssertTrue(customBinResults.maskSatisfied)
        XCTAssertEqual(customBinResults.bestMatchCardBrand?.cardBrandName, "customVisaWithTabapayCards")
    }
    
    func testCardBrandCompleteness() throws {
        let sixteenDigitCard = CardBrand.getCardBrand(text: "6582937163058334")
        
        XCTAssertTrue(sixteenDigitCard.maskSatisfied)
        
        let seventeenDigitCard = CardBrand.getCardBrand(text: "65829371630583342")
        
        XCTAssertFalse(seventeenDigitCard.maskSatisfied)
        
        let eighteenDigitCard = CardBrand.getCardBrand(text: "658293716305833421")
        
        XCTAssertFalse(eighteenDigitCard.maskSatisfied)
        
        let nineteenDigitCard = CardBrand.getCardBrand(text: "6582937163058334210")
        
        XCTAssertTrue(nineteenDigitCard.maskSatisfied)
    }
    
    func testTextThatHasNoBrand() throws {
        let textWithNoCardBrand = CardBrand.getCardBrand(text: "2937163058334684")
        
        XCTAssertFalse(textWithNoCardBrand.maskSatisfied)
        XCTAssertNil(textWithNoCardBrand.bestMatchCardBrand)
        XCTAssertEqual(textWithNoCardBrand.matchingCardBrands.count, 0)
    }
    
    func testEmptyAndNilText() throws {
        let emptyTextCardBrandResults = CardBrand.getCardBrand(text: "")
        
        XCTAssertFalse(emptyTextCardBrandResults.maskSatisfied)
        XCTAssertNil(emptyTextCardBrandResults.bestMatchCardBrand)
        XCTAssertEqual(emptyTextCardBrandResults.matchingCardBrands.count, 0)
        
        let nilTextCardBrandResults = CardBrand.getCardBrand(text: nil)
        
        XCTAssertFalse(nilTextCardBrandResults.maskSatisfied)
        XCTAssertNil(nilTextCardBrandResults.bestMatchCardBrand)
        XCTAssertEqual(nilTextCardBrandResults.matchingCardBrands.count, 0)
    }
}
