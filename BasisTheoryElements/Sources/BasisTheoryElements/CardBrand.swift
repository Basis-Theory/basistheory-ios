//
//  CardBrand.swift
//  
//
//  Created by Brian Gonzalez on 11/21/22.
//

import Foundation

public enum CardBrandName {
    case visa
    case mastercard
    case americanExpress
    case dinersClub
    case discover
    case jcb
    case unionPay
    case maestro
    case elo
    case mir
    case hiper
    case hipercard
}

let regexDigit = try! NSRegularExpression(pattern: "\\d")

public struct CardBrandDetails {
    var cardBrand: CardBrandName
    var digitIdentifiers: NSRegularExpression
    var cvcMaskInput: [NSRegularExpression]
    var cardNumberMaskInput: [Any] = []
    
    init(cardBrand: CardBrandName, digitIdentifiers: NSRegularExpression, cvcMaskInput: [NSRegularExpression], gaps: [Int], lengths: [Int]) {
        var gapIndex = 0
        for i in 1...lengths.last! {
            if (gaps[gapIndex] == i) {
                cardNumberMaskInput.append(" ")
            } else {
                cardNumberMaskInput.append(regexDigit)
            }
        }
        
        self.cardBrand = cardBrand
        self.digitIdentifiers = digitIdentifiers
        self.cvcMaskInput = cvcMaskInput
    }
}

let threeDigitCvc = [regexDigit, regexDigit, regexDigit]
let fourDigitCvc = [regexDigit, regexDigit, regexDigit]

let visaDigitIdentifiers = try! NSRegularExpression(pattern: "^4.*")
let mastercardDigitIdentifiers = try! NSRegularExpression(pattern: "^(5[1-5]|222[1-9]|22[3-9]|2[3-6]|27[0-1]|2720).*")
let amexDigitIdentifiers = try! NSRegularExpression(pattern: "^(34|37).*")
let dinersClubDigitIdentifiers = try! NSRegularExpression(pattern: "^(30[0-5]|36|38|39).*")
let discoverDigitIdentifiers = try! NSRegularExpression(pattern: "^(6011|64[4-9]|65).*")
let jcbDigitIdentifiers = try! NSRegularExpression(pattern: "^(2131|1800|35[2-8][8-9]).*")
let unionPayDigitIdentifiers = try! NSRegularExpression(pattern: "^(620|621[0-7][0-9]|6218[0-2]|6218[4-9]|6219[0-7]|6220[0-5]|6220[1-9][0-9]|622[1-9][0-9][0-9]|622018|6220[7-9]|62[3-6]|6270|6272|6276|6277[0-7][0-9]|62778[1-9]|62779[0-9]|628[2-9]|629[1-2]|810|81[1-6][0-9]|817[0-1]).*")
let maestroDigitIdentifiers = try! NSRegularExpression(pattern: "^(493698|50[0-3][0-9][0-9][0-9]|5040[0-9][0-9]|5041[0-6][0-9]|50417[0-4]|50417[6-9]|5041[8-9][0-9]|504[2-9][0-9][0-9]|505[0-9][0-9][0-9]|506[0-6][0-9][0-8]|506779|5067[8-9][0-9]|506[8-9][0-9][0-9]|50[7-8][0-9][0-9][0-9]|5[7-9]|63|67|6]).*")

struct CardBrand {
    // TODO: need to accout for variable length. may need to override element event
    public static let CardBrands: [CardBrandDetails] = [
        CardBrandDetails(cardBrand: .visa, digitIdentifiers: visaDigitIdentifiers, cvcMaskInput: threeDigitCvc, gaps: [4, 8, 12], lengths: [16, 18, 19]),
        CardBrandDetails(cardBrand: .mastercard, digitIdentifiers: mastercardDigitIdentifiers, cvcMaskInput: threeDigitCvc, gaps: [4, 8, 12], lengths: [16]),
        CardBrandDetails(cardBrand: .americanExpress, digitIdentifiers: amexDigitIdentifiers, cvcMaskInput: fourDigitCvc, gaps: [4, 10], lengths: [15]),
        CardBrandDetails(cardBrand: .dinersClub, digitIdentifiers: dinersClubDigitIdentifiers, cvcMaskInput: threeDigitCvc, gaps: [4, 10], lengths: [14, 16, 19]),
        CardBrandDetails(cardBrand: .discover, digitIdentifiers: discoverDigitIdentifiers, cvcMaskInput: threeDigitCvc, gaps: [4, 8, 12], lengths: [16, 19]),
        CardBrandDetails(cardBrand: .jcb, digitIdentifiers: jcbDigitIdentifiers, cvcMaskInput: threeDigitCvc, gaps: [4, 8, 12], lengths: [16, 17, 18, 19]),
        CardBrandDetails(cardBrand: .unionPay, digitIdentifiers: unionPayDigitIdentifiers, cvcMaskInput: threeDigitCvc, gaps: [4, 8, 12], lengths: [14, 15, 16, 17, 18, 19]),
        CardBrandDetails(cardBrand: .maestro, digitIdentifiers: maestroDigitIdentifiers, cvcMaskInput: threeDigitCvc, gaps: [4, 8, 12], lengths: [12, 13, 14, 15, 16, 17, 18, 19]),
    ]

    public static func getCardBrand(text: String) -> CardBrandDetails? {
        for cardBrand in CardBrands {
            if text.range(of: cardBrand.digitIdentifiers.pattern, options: .regularExpression) != nil {
                return cardBrand
            }
        }
        
        return nil
    }
}
