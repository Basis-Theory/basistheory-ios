//
//  TextElementUITextField.swift
//  
//
//  Created by Brian Gonzalez on 10/26/22.
//

import Foundation
import UIKit
import Combine

final public class TextElementUITextField: UITextField, InternalElementProtocol, ElementProtocol {
    func getValue() -> String? {
        super.text
    }
    
    public var subject = PassthroughSubject<ElementEvent, Error>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        subject.send(ElementEvent(type: "ready", complete: true, empty: true, errors: []))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        subject.send(ElementEvent(type: "ready", complete: true, empty: true, errors: []))
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

        subject.send(ElementEvent(type: "textChange", complete: true, empty: currentTextValue?.isEmpty ?? true, errors: []))
    }
}
