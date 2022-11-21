//
//  CardBrand.swift
//  
//
//  Created by Brian Gonzalez on 11/21/22.
//

import Foundation

enum CardBrand {
    case Visa
    case Mastercard
    case AmericanExpress
    case DinersClub
    case Discover
    case JCB
    case UnionPay
    case Maestro
    case Elo
    case MIR
    case Hiper
    case Hipercard
}

struct CardBrandDetails {
    var cardBrand: CardBrand
    var digitIdentifiers: NSRegularExpression
    var cardNumberMaskInput: [Any]
    var cvcMaskInput: [Any]
}
