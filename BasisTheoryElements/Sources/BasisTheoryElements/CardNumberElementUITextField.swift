//
//  CardNumberElementUITextField.swift
//  
//
//  Created by Lucas Chociay on 01/12/22.
//

import UIKit

final public class CardNumberUITextField: TextElementUITextField {
    private var cardBrand: CardBrandResults?
    
    override var getElementEvent: ((String?, ElementEvent) -> ElementEvent)? {
        get {
            getCardElementEvent
            
        }
        set { }
    }
    
    override var validation: ((String?) -> Bool)? {
        get {
            validateCardNumber
        }
        set { }
    }
    
    private func getCardElementEvent(text: String?, event: ElementEvent) -> ElementEvent {
        let complete = cardBrand?.complete ?? false
        let valid = self.validation?(text) ?? false
        let brand = cardBrand?.bestMatchCardBrand?.cardBrandName != nil ? String(describing: cardBrand!.bestMatchCardBrand!.cardBrandName) : "unknown"
        let brandDetail = ElementEventDetails(type: "cardBrand", message: brand)
        
        let elementEvent = ElementEvent(type: "textChange", complete: complete, empty: text?.isEmpty ?? true, valid: valid, details: [brandDetail
        ])
        
        return elementEvent
    }
    
    private func validateCardNumber(text: String?) -> Bool {
        guard text != nil else {
            return true
        }
        
        return validateLuhn(cardNumber: text!)
    }
    
    private func validateLuhn(cardNumber: String) -> Bool {
        var sum = 0
        let digitStrings = cardNumber.reversed().map { String($0) }

        for tuple in digitStrings.enumerated() {
            if let digit = Int(tuple.element) {
                let odd = tuple.offset % 2 == 1

                switch (odd, digit) {
                case (true, 9):
                    sum += 9
                case (true, 0...8):
                    sum += (digit * 2) % 9
                default:
                    sum += digit
                }
            } else {
                return false
            }
        }
        return sum % 10 == 0
    }
    
    private func updateCardMask(mask: [Any]?) {
        self.inputMask = mask
    }
    
    override var inputMask: [Any]? {
        get {
            let digitRegex = try! NSRegularExpression(pattern: "\\d")
            // TODO: modify dynamically according to card brand
            return [
                digitRegex,
                digitRegex,
                digitRegex,
                digitRegex,
                " ",
                digitRegex,
                digitRegex,
                digitRegex,
                digitRegex,
                " ",
                digitRegex,
                digitRegex,
                digitRegex,
                digitRegex,
                " ",
                digitRegex,
                digitRegex,
                digitRegex,
                digitRegex
            ]
        }
        set { }
    }
    
    override var inputTransform: ElementTransform? {
        get {
            let spaceRegex = try! NSRegularExpression(pattern: "[ \t]")
            return ElementTransform(matcher: spaceRegex)
        }
        set { }
    }
    
    override func textFieldDidChange() {
        // run event to conform to mask
        super.textFieldDidChange()
        
        if (super.getValue() != nil) {
            cardBrand = CardBrand.getCardBrand(text: super.getValue())
            
            if (cardBrand?.bestMatchCardBrand != nil) {
                updateCardMask(mask: cardBrand?.bestMatchCardBrand?.cardNumberMaskInput)
            }
        }
        
        super.textFieldDidChange()
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
