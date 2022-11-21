//
//  ElementEvents.swift
//  
//
//  Created by Brian Gonzalez on 10/26/22.
//

public struct ElementEventDetails {
    public var type: String
    public var message: String
}

public struct ElementEvent {
    public var type: String
    public var complete: Bool
    public var empty: Bool
    public var valid: Bool
    public var details: [ElementEventDetails]
}
