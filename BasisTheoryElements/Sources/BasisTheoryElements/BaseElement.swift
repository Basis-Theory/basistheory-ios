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

public protocol CardNumberElementProtocol {
    var cardTypes: [CardBrandDetails]? { get set }
}

internal protocol InternalElementProtocol {
    var validation: ((_ text: String?) -> Bool)? { get set }
    var inputMask: [Any]? { get set }
    var getElementEvent: ((_ text: String?, _ currentElementEvent: ElementEvent) -> ElementEvent)? { get set }
    var inputTransform: ElementTransform? { get set }
    func getMaskedValue() -> String?
}

public enum ElementValueType: String {
    case int = "int"
    case double = "double"
    case bool = "bool"
    case string = "string"
}

internal protocol ElementReferenceProtocol {
    func getValue() -> String?
    var getValueType: ElementValueType? { get set }
    var isComplete: Bool? { get set }
    var elementId: String { get set }
}

public enum ElementConfigError: Error {
    case invalidMask
    case configNotAllowed
    case cardBrandAlreadyExists
}

public class ElementValueReference: ElementReferenceProtocol {
    var elementId: String
    var valueMethod: (() -> String)?
    var isComplete: Bool? = true
    var getValueType: ElementValueType? = .string
    
    init(elementId: String = UUID(uuid: UUID_NULL).uuidString, valueMethod: (() -> String)?, isComplete: Bool?, getValueType: ElementValueType? = .string) {
        self.valueMethod = valueMethod
        self.isComplete = isComplete
        self.elementId = elementId
        self.getValueType = getValueType
    }
    
    func getValue() -> String? {
        return valueMethod!()
    }
}
