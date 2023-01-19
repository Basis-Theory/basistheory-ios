//
//  SplitCardElementsViewController.swift
//  IntegrationTester
//
//  Created by Brian Gonzalez on 11/10/22.
//

import Foundation
import UIKit
import BasisTheoryElements
import Combine

class SplitCardElementsViewController: UIViewController {
    private let lightBackgroundColor : UIColor = UIColor( red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0 )
    private let darkBackgroundColor : UIColor = UIColor( red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0 )
    private var cancellables = Set<AnyCancellable>()
    
    @IBOutlet weak var cardNumberTextField: CardNumberUITextField!
    @IBOutlet weak var expirationDateTextField: CardExpirationDateUITextField!
    @IBOutlet weak var cvcTextField: CardVerificationCodeUITextField!
    @IBOutlet weak var output: UITextView!
    @IBOutlet weak var cardBrand: UITextView!
    
    @IBAction func printToConsoleLog(_ sender: Any) {
        cardNumberTextField.text = "4242424242424242"
        expirationDateTextField.text = "10/26"
        cvcTextField.text = "909"
        
        print("cardNumberTextField.text: \(cardNumberTextField.text)")
        print("expirationDateTextField.text: \(expirationDateTextField.text)")
        print("cvcTextField.text: \(cvcTextField.text)")
    }
    
    @IBAction func tokenize(_ sender: Any) {
        class MyStructData: BTEncodable {
            var number: CardNumberUITextField
            var expirationMonth: ElementValueReference
            var expirationYear: ElementValueReference
            var cvc: CardVerificationCodeUITextField
            
            init(number: CardNumberUITextField, expirationMonth: ElementValueReference, expirationYear: ElementValueReference, cvc: CardVerificationCodeUITextField) {
                self.number = number
                self.expirationMonth = expirationMonth
                self.expirationYear = expirationYear
                self.cvc = cvc
                super.init()
            }
            
            private enum CodingKeys: String, CodingKey {
                case number
                
            }
            
            required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                number = try container.decode(String.self, forKey: .number)
            }
        }
        
        class MyStruct: BTEncodable {
            var data: MyStructData
            var type: String
            
            init(data: MyStructData, type: String) {
                self.data = data
                self.type = type
                super.init()
            }
            
            required init(from decoder: Decoder) throws {
                fatalError("init(from:) has not been implemented")
            }
        }
          
        let body = MyStruct(data: MyStructData(number: self.cardNumberTextField, expirationMonth: self.expirationDateTextField.month(), expirationYear: self.expirationDateTextField.year(), cvc: self.cvcTextField), type: "card")
//        let body: [String: Any] = [
//            "data": [
//                "number": self.cardNumberTextField,
//                "expiration_month": self.expirationDateTextField.month(),
//                "expiration_year": self.expirationDateTextField.year(),
//                "cvc": self.cvcTextField
//            ],
//            "type": "card"
//        ]
        
        // this next line is used for our own testing purposes. you can simply pass in your public API key into the tokenize request below
        let config = Configuration.getConfiguration()
        BasisTheoryElements.tokenize(body: body, apiKey: config.btApiKey!) { (_ data: MyStruct?, _ error: Error?) -> Void in
            guard error == nil else {
                self.output.text = "There was an error!"
                print(error)
                return
            }
            
//            let stringifiedData = String(data: try! JSONSerialization.data(withJSONObject: data!.value as! [String: Any], options: .prettyPrinted), encoding: .utf8)!
            
            self.output.text = String(describing: data)
            print(String(describing: data))
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setStyles(textField: cardNumberTextField, placeholder: "Card Number")
        setStyles(textField: expirationDateTextField, placeholder: "MM/YY")
        setStyles(textField: cvcTextField, placeholder: "CVC")
        
        let cvcOptions = CardVerificationCodeOptions(cardNumberUITextField: cardNumberTextField)
        cvcTextField.setConfig(options: cvcOptions)
        
        cardNumberTextField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            print("cardNumber:")
            print(message)
            
            if (!message.details.isEmpty) {
                let brandDetails = message.details[0]
                
                self.cardBrand.text = brandDetails.type + ": " + brandDetails.message
            }
        }.store(in: &cancellables)
        
        expirationDateTextField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            print("expirationDate:")
            print(message)
        }.store(in: &cancellables)
        
        cvcTextField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            print("CVC:")
            print(message)
        }.store(in: &cancellables)
    }
    
    private func setStyles(textField: UITextField, placeholder: String) {
        textField.layer.cornerRadius = 15.0
        textField.placeholder = placeholder
        textField.backgroundColor = lightBackgroundColor
        textField.addTarget(self, action: #selector(didBeginEditing(_:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(didEndEditing(_:)), for: .editingDidEnd)
    }
    
    @objc private func didBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = darkBackgroundColor
    }
    
    @objc private func didEndEditing(_ textField: UITextField) {
        textField.backgroundColor = lightBackgroundColor
    }
}
