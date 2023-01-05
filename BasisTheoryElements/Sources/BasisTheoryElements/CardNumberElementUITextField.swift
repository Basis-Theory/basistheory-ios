//
//  CardNumberElementUITextField.swift
//  
//
//  Created by Lucas Chociay on 01/12/22.
//

import UIKit

final public class CardNumberUITextField: TextElementUITextField {
    internal var cardBrand: CardBrandResults?
    private var cardMask: [Any]?
    
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
    
    override var inputMask: [Any]? {
        get {
            if cardMask != nil {
                return self.cardMask
            } else {
                return getDefaultCardMask()
            }
        }
        set {
            
        }
    }
    
    public override func setConfig(options: TextElementOptions?) throws {
        throw ElementConfigError.configNotAllowed
    }
    
    private func getDefaultCardMask() -> [Any] {
        let regexDigit = try! NSRegularExpression(pattern: "\\d")
        return [
            regexDigit,
            regexDigit,
            regexDigit,
            regexDigit,
            " ",
            regexDigit,
            regexDigit,
            regexDigit,
            regexDigit,
            " ",
            regexDigit,
            regexDigit,
            regexDigit,
            regexDigit,
            " ",
            regexDigit,
            regexDigit,
            regexDigit,
            regexDigit
        ]
    }
    
    private func getCardElementEvent(text: String?, event: ElementEvent) -> ElementEvent {
        let complete = cardBrand?.complete ?? false
        let brand = cardBrand?.bestMatchCardBrand?.cardBrandName != nil ? String(describing: cardBrand!.bestMatchCardBrand!.cardBrandName) : "unknown"
        var details = [ElementEventDetails(type: "cardBrand", message: brand)]
        
        if complete {
            details.append(ElementEventDetails(type: "cardLast4", message: String(text!.suffix(4))))
            details.append(ElementEventDetails(type: "cardBin", message: String(text!.prefix(6))))
        }
        
        let elementEvent = ElementEvent(type: "textChange", complete: complete, empty: event.empty, valid: event.valid, details: details)
        
        return elementEvent
    }
    
    private func validateCardNumber(text: String?) -> Bool {
        guard text != nil else {
            return false
        }
        
        return validateLuhn(cardNumber: text)
    }
    
    private func validateLuhn(cardNumber: String?) -> Bool {
        guard cardNumber != "" else {
            return false
        }
        
        var sum = 0
        let digitStrings = cardNumber?.reversed().map { String($0) }
        
        for tuple in digitStrings!.enumerated() {
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
        self.cardMask = mask
    }
    
    override var inputTransform: ElementTransform? {
        get {
            let spaceRegex = try! NSRegularExpression(pattern: "[ \t]")
            return ElementTransform(matcher: spaceRegex)
        }
        set { }
    }
    
    override func textFieldDidChange() {
        if (super.getValue() != nil) {
            guard Int(super.getValue()!) != nil else {
                cardBrand = nil
                super.textFieldDidChange()
                return
            }
            
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
