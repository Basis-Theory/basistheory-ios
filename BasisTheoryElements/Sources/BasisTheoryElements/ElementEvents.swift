//
//  ElementEvents.swift
//  
//
//  Created by Brian Gonzalez on 10/26/22.
//

import Foundation

public struct ElementEventErrors {
    public var type: String
}

public struct ElementEvent {
    public var type: String
    public var complete: Bool
    public var empty: Bool
    public var errors: [ElementEventErrors]
}
