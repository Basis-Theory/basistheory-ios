//
//  BaseElement.swift
//  
//
//  Created by Brian Gonzalez on 10/26/22.
//

import Foundation
import Combine

public protocol ElementProtocol {
    var subject: PassthroughSubject<ElementEvent, Error> {get set}
}

internal protocol InternalElementProtocol {
    var validation: ((_ text: String?) -> Bool)? { get set }
    
    func getValue() -> String?
}

public enum ElementConfigError: Error {
    case invalidMask
}

public struct ElementOptions {
    let mask: [Any]?
    
    public init(mask: [Any]?) {
        self.mask = mask
    }
}