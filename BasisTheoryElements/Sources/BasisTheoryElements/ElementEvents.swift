//
//  ElementEvents.swift
//  
//
//  Created by Brian Gonzalez on 10/26/22.
//

public struct ElementEventDetails: Encodable {
    public var type: String
    public var message: String
}

public struct ElementEvent: Encodable {
    public var type: String
    public var complete: Bool
    public var empty: Bool
    public var valid: Bool
    public var maskSatisfied: Bool
    public var details: [ElementEventDetails]
}
