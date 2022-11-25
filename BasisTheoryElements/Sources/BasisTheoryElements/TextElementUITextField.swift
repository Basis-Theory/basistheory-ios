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
    public var validation: ((String?) -> Bool)?
    public var inputMask: [(Any)]?
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
                super.text = conformToMask(text: newValue!)
            } else {
                super.text = newValue
            }
        }
        get { nil }
    }
    
    private func conformToMask(text: String) -> String {
        var maskIndex = 0
        var maskedText = ""

        for char in text {
            guard maskIndex < inputMask!.count else{
                return maskedText
            }

            let maskValue = inputMask![maskIndex]
            let maskedChar = getMaskedChar(char: String(char), maskValue: maskValue)
            
            if maskValue is NSRegularExpression {
                maskedText = maskedText + maskedChar
                
                if (maskedChar !=  "") {
                    maskIndex += 1
                }
            } else if maskValue is String {
                maskIndex += 1

                if String(char) != (maskValue as! String) {
                    let nextMaskedChar = getMaskedChar(char: String(char), maskValue: inputMask![maskIndex])
                    maskedText =  maskedText + (maskValue as! String) + nextMaskedChar
                    
                    if (nextMaskedChar != "") {
                        maskIndex += 1
                    }
                } else {
                    maskedText = maskedText + String(char)
                }
            }
        }

        return maskedText
    }
    
    private func getMaskedChar(char: String, maskValue: Any) -> String{
        if maskValue is NSRegularExpression {
            let regex = maskValue as! NSRegularExpression

            if String(char).range(of: regex.pattern, options: .regularExpression) != nil {
                return String(char)
            }
        } else if maskValue is String {
            if String(char) != (maskValue as! String) {
                return String(char) + (maskValue as! String)
            }
        }
        
        return ""
    }
    
    @objc private func textFieldDidChange() {
        if inputMask != nil {
            let previousValue = super.text

            super.text = conformToMask(text: super.text!)

            guard previousValue == super.text else {
                return
            }
        }

        let currentTextValue = super.text
        var invalid = false

        if let validation = validation {
            invalid = !validation(currentTextValue)
        }
        
        let complete = !invalid
        
        subject.send(ElementEvent(type: "textChange", complete: complete, empty: currentTextValue?.isEmpty ?? true, invalid: invalid))
    }
    
    func getValue() -> String? {
        super.text
    }
}
