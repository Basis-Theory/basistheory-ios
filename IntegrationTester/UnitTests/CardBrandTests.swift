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
    func testBestMatchAndMatchingCardBrandsReturned() throws {
        let regexDigit = try! NSRegularExpression(pattern: "\\d")
        let threeDigitCvc = [regexDigit, regexDigit, regexDigit]
        let cardBrandResults = CardBrand.getCardBrand(text: "650032")
        
        XCTAssertFalse(cardBrandResults.complete)
        
        XCTAssertEqual(cardBrandResults.bestMatchCardBrand!.cardBrandName, CardBrand.CardBrandName.elo)
        XCTAssertEqual(cardBrandResults.bestMatchCardBrand!.cvcMaskInput, threeDigitCvc)
        XCTAssertEqual(cardBrandResults.bestMatchCardBrand!.validLengths, [16])
        XCTAssertEqual(cardBrandResults.bestMatchCardBrand!.cardNumberMaskInput.count, 19)

        XCTAssertEqual(cardBrandResults.matchingCardBrands[0].cardBrandName, CardBrand.CardBrandName.discover)
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
    
    func testCardBrandCompleteness() throws {
        let sixteenDigitCard = CardBrand.getCardBrand(text: "6582937163058334")

        XCTAssertTrue(sixteenDigitCard.complete)
        
        let seventeenDigitCard = CardBrand.getCardBrand(text: "65829371630583342")
        
        XCTAssertFalse(seventeenDigitCard.complete)
        
        let eighteenDigitCard = CardBrand.getCardBrand(text: "658293716305833421")
        
        XCTAssertFalse(eighteenDigitCard.complete)
        
        let nineteenDigitCard = CardBrand.getCardBrand(text: "6582937163058334210")
        
        XCTAssertTrue(nineteenDigitCard.complete)
    }
    
    func testTextThatHasNoBrand() throws {
        let textWithNoCardBrand = CardBrand.getCardBrand(text: "2937163058334684")
        
        XCTAssertFalse(textWithNoCardBrand.complete)
        XCTAssertNil(textWithNoCardBrand.bestMatchCardBrand)
        XCTAssertEqual(textWithNoCardBrand.matchingCardBrands.count, 0)
    }
    
    func testEmptyAndNilText() throws {
        let emptyTextCardBrandResults = CardBrand.getCardBrand(text: "")
        
        XCTAssertFalse(emptyTextCardBrandResults.complete)
        XCTAssertNil(emptyTextCardBrandResults.bestMatchCardBrand)
        XCTAssertEqual(emptyTextCardBrandResults.matchingCardBrands.count, 0)
        
        let nilTextCardBrandResults = CardBrand.getCardBrand(text: nil)
        
        XCTAssertFalse(nilTextCardBrandResults.complete)
        XCTAssertNil(nilTextCardBrandResults.bestMatchCardBrand)
        XCTAssertEqual(nilTextCardBrandResults.matchingCardBrands.count, 0)
    }
}
