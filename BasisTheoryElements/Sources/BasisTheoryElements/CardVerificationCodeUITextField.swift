//
//  CardVerificationCodeUITextField.swift
//  
//
//  Created by Brian Gonzalez on 11/10/22.
//

import UIKit
import Combine

public struct CardVerificationCodeOptions {
    let cardNumberUITextField: CardNumberUITextField?
    
    public init(cardNumberUITextField: CardNumberUITextField? = nil) {
        self.cardNumberUITextField = cardNumberUITextField
    }
}

final public class CardVerificationCodeUITextField: TextElementUITextField {
    private var cardNumberUITextField: CardNumberUITextField?
    private var cancellables = Set<AnyCancellable>()
    private var cvcMask: [Any]?
    
    override var validation: ((String?) -> Bool)? {
        get {
            validateCvc
        }
        set { }
    }
    
    private func validateCvc(text: String?) -> Bool {
        guard text != nil else {
            return false
        }
        
        return text!.range(of: "^[0-9]{3,4}$", options: .regularExpression) != nil
    }
    
    override var inputMask: [Any]? {
        get {
            if cvcMask != nil {
                return self.cvcMask
            } else {
                return self.getDefaultCvcMask()
            }
        }
        set {
            
        }
    }
    
    private func getDefaultCvcMask() -> [Any] {
        let regexDigit = try! NSRegularExpression(pattern: "\\d")
        return [
            regexDigit,
            regexDigit,
            regexDigit,
            regexDigit
        ]
    }
    
    public func setConfig(options: CardVerificationCodeOptions) {
        if (options.cardNumberUITextField != nil) {
            self.cardNumberUITextField = options.cardNumberUITextField
            
            self.cardNumberUITextField!.subject.sink { completion in
                //
            } receiveValue: { message in
                if (message.type == "textChange") {
                    self.updateCvcMask()
                }
            }.store(in: &cancellables)
        }
    }
    
    private func updateCvcMask() {
        guard cardNumberUITextField != nil else {
            return
        }
        
        var brand = cardNumberUITextField?.cardBrand?.bestMatchCardBrand
        
        if brand != nil {
            self.cvcMask = brand?.cvcMaskInput
        }
        
        return
    }
    
    public override func setConfig(options: TextElementOptions?) throws {
        throw ElementConfigError.configNotAllowed
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
