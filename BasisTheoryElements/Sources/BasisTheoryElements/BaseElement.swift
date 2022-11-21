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
    
    var getElementEvent: ((_ text: String?) -> ElementEvent)? { get set }
    
    func getValue() -> String?
}
