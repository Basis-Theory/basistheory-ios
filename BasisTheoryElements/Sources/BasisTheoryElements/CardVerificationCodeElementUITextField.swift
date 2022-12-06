//
//  CardVerificationCodeElementUITextField.swift
//  
//
//  Created by Brian Gonzalez on 11/10/22.
//

import UIKit

final public class CardVerificationCodeElementUITextField: TextElementUITextField {
    override var validation: ((String?) -> Bool)? {
        get {
            validateCvc
        }
        set { }
    }
    
    private func validateCvc(text: String?) -> Bool {
        guard text != nil else {
            return true
        }
        
        return text!.range(of: "^[0-9]{3,4}$", options: .regularExpression) != nil
    }
    
    public override func setConfig(options: TextElementOptions?) throws {
        if (options?.mask != nil) {
            throw ElementConfigError.configNotAllowed
        } else if (options?.transform != nil) {
            throw ElementConfigError.configNotAllowed
        }
        
        try super.setConfig(options: options)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.keyboardType = .asciiCapableNumberPad
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.keyboardType = .asciiCapableNumberPad
    }
}
