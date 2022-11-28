//
//  TextElementUITextField.swift
//  
//
//  Created by Brian Gonzalez on 10/26/22.
//

import Foundation
import UIKit
import Combine

public class TextElementUITextField: UITextField, InternalElementProtocol, ElementProtocol {
    var validation: ((String?) -> Bool)?
    var backspacePressed: Bool = false
    var inputMask: [(Any)]?

    public var subject = PassthroughSubject<ElementEvent, Error>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.smartDashesType = .no
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        subject.send(ElementEvent(type: "ready", complete: true, empty: true, invalid: false))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.smartDashesType = .no
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        subject.send(ElementEvent(type: "ready", complete: true, empty: true, invalid: false))
    }
    
    deinit {
        subject.send(completion: .finished)
    }
    
    public override var text: String? {
        set {
            if inputMask != nil {
                super.text = conformToMask(text: newValue ?? "")
            } else {
                super.text = newValue
            }
        }
        get { nil }
    }
    
    // detecting backspace, used for masking
    override public func deleteBackward() {
        self.backspacePressed = true
        super.deleteBackward()
    }
    
    public func setConfig(options: ElementOptions?) throws {
        if (options?.mask != nil) {
            guard validateMask(inputMask: (options?.mask)!) else {
                throw ElementConfigError.invalidMask
            }
            
            self.inputMask = options?.mask
        }
    }
    
    private func validateMask(inputMask: [(Any)]) -> Bool {
        for maskValue in inputMask {
            guard (maskValue is String && (maskValue as! String).count == 1) || maskValue is NSRegularExpression else {
                return false
            }
        }
        
        return true
    }
    
    private func conformToMask(text: String) -> String {
        var userInput = text
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
                // found a gap for user input
                if String(char) == placeholderChar {
                    // start going through user input to fill array
                    var validChar = ""

                    while (userInput.count > 0) {
                        let firstChar = userInput.removeFirst()
                        
                        // regex matches, is valid, we can add
                        let regex = inputMask![maskIndex] as! NSRegularExpression
                        if String(firstChar).range(of: regex.pattern, options: .regularExpression) != nil {
                            validChar = String(firstChar)
                            break // move to next placeholder position
                        }
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
    
    @objc private func textFieldDidChange() {
        var maskComplete = true

        if inputMask != nil {
            let previousValue = super.text
            
            // dont conform on backspace pressed - just remove the value
            if (!backspacePressed) {
                super.text = conformToMask(text: super.text ?? "")
            } else {
                backspacePressed = false
            }
            
            if (super.text?.count != inputMask!.count ) {
                maskComplete = false
            }

            guard previousValue == super.text else {
                return
            }
        }

        let currentTextValue = super.text
        var invalid = false

        if let validation = validation {
            invalid = !validation(currentTextValue)
        }
        
        let complete = !invalid && maskComplete
        
        subject.send(ElementEvent(type: "textChange", complete: complete, empty: currentTextValue?.isEmpty ?? true, invalid: invalid))
    }
    
    func getValue() -> String? {
        super.text
    }
}
