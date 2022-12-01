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
    var inputMask: [Any]? { get set }
    var getElementEvent: ((_ text: String?, _ currentElementEvent: ElementEvent) -> ElementEvent)? { get set }
    var inputTransform: ElementTransform? { get set }
}
    
internal protocol ElementReferenceProtocol {
    func getValue() -> String?
}

public enum ElementConfigError: Error {
    case invalidMask
}

public class ElementValueReference: ElementReferenceProtocol {
    var valueMethod: (() -> String)?
    
    init(valueMethod: (() -> String)?) {
        self.valueMethod = valueMethod
    }

    func getValue() -> String? {
        return valueMethod!()
    }
}
