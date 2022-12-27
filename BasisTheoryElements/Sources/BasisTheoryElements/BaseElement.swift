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
    func setValue(elementValueReference: ElementValueReference?) -> Void
}

internal protocol InternalElementProtocol {
    var validation: ((_ text: String?) -> Bool)? { get set }
    var inputMask: [Any]? { get set }
    var getElementEvent: ((_ text: String?, _ currentElementEvent: ElementEvent) -> ElementEvent)? { get set }
    var inputTransform: ElementTransform? { get set }
}

internal protocol ElementReferenceProtocol {
    func getValue() -> String?
    var isValid: Bool? { get set }
}

public enum ElementConfigError: Error {
    case invalidMask
    case configNotAllowed
}

public class ElementValueReference: ElementReferenceProtocol {
    var valueMethod: (() -> String)?
    var isValid: Bool? = true
    
    init(valueMethod: (() -> String)?, isValid: Bool?) {
        self.valueMethod = valueMethod
        self.isValid = isValid
    }

    func getValue() -> String? {
        return valueMethod!()
    }
}
