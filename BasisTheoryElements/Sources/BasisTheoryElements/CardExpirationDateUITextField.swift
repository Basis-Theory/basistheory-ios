//
//  CardExpirationDateUITextField.swift
//
//
//  Created by Lucas Chociay on 11/28/22.
//

import UIKit

final public class CardExpirationDateUITextField: TextElementUITextField {
    override var validation: ((String?) -> Bool)? {
        get {
            validateExpirationDate
        }
        set { }
    }
    
    private func validateExpirationDate(text: String?) -> Bool {
        guard text != nil else {
            return false
        }
        
        // check date is MM/YY -> 5 chars.
        guard text?.count == 5 else {
            return false
        }
        
        return validateFutureDate(text: text!)
    }
    
    public override func setConfig(options: TextElementOptions?) throws {
        throw ElementConfigError.configNotAllowed
    }
    
    private func validateFutureDate(text: String) -> Bool {
        let inputDateArray = super.getValue()?.components(separatedBy: "/")
        let inputMonth = Int(String(inputDateArray![0]))!
        let inputYear = Int(String("20" + inputDateArray![1]))!
        
        let now = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "YYYY"
        let currentYear = Int(dateFormatter.string(from: now))!
        if inputYear > currentYear {
            return true
        } else if inputYear == currentYear {
            dateFormatter.dateFormat = "MM"
            let currentMonth = Int(dateFormatter.string(from: now))!
            
            return inputMonth >= currentMonth
        } else {
            return false
        }
    }
    
    override var inputMask: [Any]? {
        get {
            let digitRegex = try! NSRegularExpression(pattern: "\\d")
            return [digitRegex, digitRegex, "/", digitRegex, digitRegex]
        }
        set { }
    }
    
    public func month() -> ElementValueReference {
        let monthReference = ElementValueReference(valueMethod: getMonthValue, isValid: self.isValid)
        return monthReference
    }
    
    public func year() -> ElementValueReference {
        let yearReference = ElementValueReference(valueMethod: getYearValue, isValid: self.isValid)
        return yearReference
    }
    
    private func getMonthValue() -> String {
        if (super.getValue() != nil){
            let dateArray = super.getValue()?.components(separatedBy: "/")
            return String(dateArray![0])
        }
        
        return ""
    }
    
    private func getYearValue() -> String {
        if (super.getValue() != nil) {
            let dateArray = super.getValue()?.components(separatedBy: "/")
            return String("20" + dateArray![1])
        }
        
        return ""
    }
    
    override func textFieldDidChange() {
        if (super.getValue()!.count > 0) {
            let firstChar = super.getValue()?.first
            
            // check first char, if > 1 add 0 in front
            if (firstChar?.wholeNumberValue!)! > 1  {
                super.text = "0" + super.getValue()!
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
