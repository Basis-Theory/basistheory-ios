//
//  BaseElement.swift
//  
//
//  Created by Brian Gonzalez on 10/26/22.
//

import Foundation
import Combine

public protocol ElementProtocol {
    var subject: PassthroughSubject<ElementEvent, Error> { get set }
    var metadata: ElementMetadata { get }
    func setValue(elementValueReference: ElementValueReference?) -> Void
    func setValueRef(element: TextElementUITextField) -> Void
    var elementId: String { get set }
}

public protocol CardElementProtocol {
    var cardMetadata: CardMetadata { get }
}

internal protocol InternalElementProtocol {
    var validation: ((_ text: String?) -> Bool)? { get set }
    var inputMask: [Any]? { get set }
    var getElementEvent: ((_ text: String?, _ currentElementEvent: ElementEvent) -> ElementEvent)? { get set }
    var inputTransform: ElementTransform? { get set }
    func getMaskedValue() -> String?
}

internal protocol ElementReferenceProtocol {
    func getValue() -> Any?
    var isComplete: Bool? { get set }
    var elementId: String { get set }
}

public enum ElementConfigError: Error {
    case invalidMask
    case configNotAllowed
}

public class ElementValueReference: ElementReferenceProtocol {
    var elementId: String
    var valueMethod: (() -> Any)?
    var isComplete: Bool? = true
    
    init(elementId: String = UUID(uuid: UUID_NULL).uuidString, valueMethod: (() -> Any)?, isComplete: Bool?) {
        self.valueMethod = valueMethod
        self.isComplete = isComplete
        self.elementId = elementId
    }

    func getValue() -> Any? {
        return valueMethod!()
    }
}
