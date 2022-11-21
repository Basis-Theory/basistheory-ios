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
    
    var getElementEvent: ((String?) -> ElementEvent)?
    
    public var subject = PassthroughSubject<ElementEvent, Error>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        subject.send(ElementEvent(type: "ready", complete: true, empty: true, valid: true, details: []))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        subject.send(ElementEvent(type: "ready", complete: true, empty: true, valid: true, details: []))
    }
    
    deinit {
        subject.send(completion: .finished)
    }
    
    public override var text: String? {
        set {
            super.text = newValue
        }
        get { nil }
    }
    
    @objc private func textFieldDidChange() {
        let currentTextValue = super.text
        var valid = false

        if let validation = validation {
            valid = validation(currentTextValue)
        }
        
        let complete = valid
        
        var elementEvent = ElementEvent(type: "textChange", complete: complete, empty: currentTextValue?.isEmpty ?? true, valid: valid, details: [])
        
        if let getElementEvent = getElementEvent {
            elementEvent = getElementEvent(currentTextValue)
        }
        
        subject.send(elementEvent)
    }
    
    func getValue() -> String? {
        super.text
    }
}
