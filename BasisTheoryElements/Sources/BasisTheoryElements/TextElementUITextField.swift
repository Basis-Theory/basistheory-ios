//
//  TextElementUITextField.swift
//  
//
//  Created by Brian Gonzalez on 10/26/22.
//

import Foundation
import UIKit
import Combine

public struct TextElementOptions {
    let mask: [Any]?
    let transform: ElementTransform?
    
    public init(mask: [Any]? = nil, transform: ElementTransform? = nil) {
        self.mask = mask
        self.transform = transform
    }
}

public class TextElementUITextField: UITextField, InternalElementProtocol, ElementProtocol, ElementReferenceProtocol {
    var isComplete: Bool? = true
    var getElementEvent: ((String?, ElementEvent) -> ElementEvent)?
    var validation: ((String?) -> Bool)?
    var backspacePressed: Bool = false
    var inputMask: [Any]?
    var inputTransform: ElementTransform?
    var previousValue: String = ""
    var readOnly: Bool = false
    var valueRef: TextElementUITextField?
    private var cancellables = Set<AnyCancellable>()
    
    public var subject = PassthroughSubject<ElementEvent, Error>()
    public var metadata: ElementMetadata = ElementMetadata(complete: true, empty: true, valid: true, maskSatisfied: false)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.smartDashesType = .no
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        subject.send(ElementEvent(type: "ready", complete: true, empty: true, valid: true, maskSatisfied: false, details: []))
    }
    
    deinit {
        subject.send(completion: .finished)
    }
    
    public override var text: String? {
        set {
            if inputMask != nil {
                super.text = conformToMask(text: newValue)
            } else {
                super.text = newValue
            }
            
            if let validation = validation {
                self.isComplete = self.isComplete ?? true && validation(transform(text: newValue))
            }
        }
        get { nil }
    }
    
    public override var isUserInteractionEnabled: Bool {
        set {
            if (!readOnly) {
                super.isUserInteractionEnabled = newValue
            }
        }
        get { super.isUserInteractionEnabled }
    }
    
    public func setValue(elementValueReference: ElementValueReference?) {
        if let elementValueReference = elementValueReference {
            self.text = elementValueReference.getValue()
        }
    }
    
    public func setValueRef(element: TextElementUITextField) {
        self.isUserInteractionEnabled = false
        self.readOnly = true
            
        self.valueRef = element
        self.valueRef!.subject.sink { completion in } receiveValue: { message in
            if (message.type == "textChange") {
                self.text = self.valueRef?.getValue()
            }
        }.store(in: &cancellables)
    }
    
    // detecting backspace, used for masking
    override public func deleteBackward() {
        self.backspacePressed = true
        super.deleteBackward()
    }
    
    public func setConfig(options: TextElementOptions?) throws {
        if (options?.mask != nil) {
            guard validateMask(inputMask: (options?.mask)!) else {
                throw ElementConfigError.invalidMask
            }
            
            self.inputMask = options?.mask
        }
        
        if (options?.transform != nil) {
            self.inputTransform = options?.transform
        }
    }
    
    private func transform(text: String?) -> String {
        guard let transformedText = inputTransform?.matcher.stringByReplacingMatches(in: text ?? "", options: .reportCompletion, range: NSRange(location: 0, length: text?.count ?? 0), withTemplate: (inputTransform?.stringReplacement)!) else { return text ?? "" }
        return transformedText
    }
    
    private func validateMask(inputMask: [(Any)]) -> Bool {
        for maskValue in inputMask {
            guard (maskValue is String && (maskValue as! String).count == 1) || maskValue is NSRegularExpression else {
                return false
            }
        }
        
        return true
    }
    
    private func conformToMask(text: String?) -> String {
        var userInput = text ?? ""
        let placeholderChar = "_"
        var placeholderString = ""
        var maskedText = ""
        
        // create placeholder string
        for maskValue in inputMask! as [(Any)] {
            if maskValue is NSRegularExpression {
                placeholderString.append(placeholderChar)
            } else if maskValue is String {
                placeholderString.append(maskValue as! String)
            }
        }
        
        var maskIndex = 0
        
        // run through placeholder string, replace gaps w/ user input
        for char in placeholderString {
            if (userInput.count > 0) {
                if String(char) == placeholderChar {
                    // start going through user input to fill array
                    var validChar = ""
                    
                    while (userInput.count > 0) {
                        let firstChar = userInput.removeFirst()
                        
                        // check for placeholder char in mask
                        if (inputMask![maskIndex] is String) {
                            maskedText.append(inputMask![maskIndex] as! String)
                            break
                        } else {
                            
                            // regex matches, is valid, we can add
                            let regex = inputMask![maskIndex] as! NSRegularExpression
                            if String(firstChar).range(of: regex.pattern, options: .regularExpression) != nil {
                                validChar = String(firstChar)
                                break // move to next placeholder position
                            }}
                    }
                    
                    maskedText.append(validChar)
                } else {
                    // just add the char as its the string part of the mask
                    maskedText.append(String(char))
                }
            }
            maskIndex += 1
        }
        
        return maskedText
    }
    
    public override func insertText(_ text: String) {
        if inputMask != nil {
            super.insertText(conformToMask(text: text))
        } else {
            super.insertText(text)
        }
        
        if let validation = validation {
            self.isComplete = self.isComplete ?? true && validation(transform(text: text))
        }
    }
    
    @objc func textFieldDidChange() {
        var maskComplete = true
        
        if let inputMask = inputMask {
            // dont conform on backspace pressed - just remove the value + check for backspace on empty
            if (!backspacePressed || super.text != nil) {
                super.text = conformToMask(text: super.text)
            } else {
                backspacePressed = false
            }
            
            maskComplete = super.text?.count == inputMask.count
        }
        
        let transformedTextValue = self.transform(text: super.text)
        var valid = true

        if let validation = validation {
            valid = validation(transformedTextValue)
        }
        
        let complete = valid && maskComplete
        
        self.isComplete = complete
        
        var elementEvent = ElementEvent(type: "textChange", complete: complete, empty: transformedTextValue.isEmpty, valid: valid, maskSatisfied: maskComplete, details: [])
        
        if let getElementEvent = getElementEvent {
            elementEvent = getElementEvent(transformedTextValue, elementEvent)
        }
        
        self.metadata = ElementMetadata(complete: elementEvent.complete, empty: elementEvent.empty, valid: elementEvent.valid, maskSatisfied: elementEvent.maskSatisfied)
        
        // prevents sending an additional event if input didn't change
        if (previousValue == super.text) {
            return
        } else {
            previousValue = super.text!
        }
        
        subject.send(elementEvent)
    }
    
    func getValue() -> String? {
        return transform(text: super.text)
    }
}
