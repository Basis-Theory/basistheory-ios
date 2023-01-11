//
//  ElementMetadata.swift
//  
//
//  Created by Lucas Chociay on 10/01/23.
//

import Foundation

public struct ElementMetadata {
    public var complete: Bool
    public var empty: Bool
    public var valid: Bool
    public var maskSatisfied: Bool
}

public struct CardMetadata {
    public var cardLast4: String?
    public var cardBin: String?
    public var cardBrand: String
}
