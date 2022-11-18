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
    
    public var subject = PassthroughSubject<ElementEvent, Error>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        subject.send(ElementEvent(type: "ready", complete: true, empty: true, invalid: false))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        subject.send(ElementEvent(type: "ready", complete: true, empty: true, invalid: false))
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
