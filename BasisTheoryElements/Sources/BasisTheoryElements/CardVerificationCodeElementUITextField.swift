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
    
    // TODO: feed card brand to change mask size
    override var inputMask: [Any]? {
        get {
            let digitRegex = try! NSRegularExpression(pattern: "\\d")
            return [digitRegex, digitRegex, digitRegex, digitRegex]
        }
        set { }
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
