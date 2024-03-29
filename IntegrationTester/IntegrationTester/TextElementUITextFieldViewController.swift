//
//  ViewController.swift
//  IntegrationTester
//
//  Created by Brian Gonzalez on 10/18/22.
//

import UIKit
import Combine
import BasisTheoryElements

class TextElementUITextFieldViewController: UIViewController {
    private let lightBackgroundColor : UIColor = UIColor( red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0 )
    private let darkBackgroundColor : UIColor = UIColor( red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0 )
    private var cancellables = Set<AnyCancellable>()

    @IBOutlet private weak var nameTextField: TextElementUITextField!
    @IBOutlet weak var output: UITextView!
    @IBOutlet private weak var phoneNumberTextField: TextElementUITextField!
    @IBOutlet private weak var readOnlyTextField: TextElementUITextField!
    
    @IBAction func printToConsoleLog(_ sender: Any) {
        nameTextField.text = "Tom Cruise"
        phoneNumberTextField.text = "555-123-4567"
        
        print("nameTextField.text: \(nameTextField.text)")
        print("phoneTextField.text: \(phoneNumberTextField.text)")
    }
    
    @IBAction func tokenize(_ sender: Any) {
        let body: [String: Any] = [
            "data": [
                "name": self.nameTextField,
                "phoneNumber": self.phoneNumberTextField,
                "myProp": "myValue",
                "object": [
                    "nestedProp": "nestedValue",
                    "phoneNumber": self.phoneNumberTextField,
                ]
            ],
            "search_indexes": ["{{ data.phoneNumber }}"],
            "type": "token"
        ]
        
        // this next line is used for our own testing purposes. you can simply pass in your public API key into the tokenize request below
        let config = Configuration.getConfiguration()
        BasisTheoryElements.tokenize(body: body, apiKey: config.btApiKey!) { data, error in
            guard error == nil else {
                self.output.text = "There was an error!"
                print(error)
                return
            }

            let stringifiedData = String(data: try! JSONSerialization.data(withJSONObject: data!.value as! [String: Any], options: .prettyPrinted), encoding: .utf8)!

            self.output.text = stringifiedData
            print(stringifiedData)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nameOptions = TextElementOptions(enableCopy: true, copyIconColor: UIColor.red)
        try! nameTextField.setConfig(options: nameOptions)
        
        let readOnlyOptions = TextElementOptions(enableCopy: true)
        try! readOnlyTextField.setConfig(options: readOnlyOptions)
        
        let regexDigit = try! NSRegularExpression(pattern: "\\d")
        let phoneMask = [ // (123)456-7890
            "(",
            regexDigit,
            regexDigit,
            regexDigit,
            ")",
            regexDigit,
            regexDigit,
            regexDigit,
            "-",
            regexDigit,
            regexDigit,
            regexDigit,
            regexDigit
        ] as [Any]
       
        let transformMatcher = try! NSRegularExpression(pattern: "[()-]") // Regex to remove parentheses & dashes
        // "^\\(\\d{3}\\)\\d{3}-\\d{4}$" regex for validation without a transform
        let phoneNumberRegex = try! NSRegularExpression(pattern: "^\\d{10}$") // Regex to validate phone number after transform
        
        let phoneOptions = TextElementOptions(mask: phoneMask, transform: ElementTransform(matcher: transformMatcher), validation: phoneNumberRegex)
        
        try! phoneNumberTextField.setConfig(options: phoneOptions)
        
        readOnlyTextField.setValueRef(element: nameTextField)
        
        setStyles(textField: nameTextField, placeholder: "Name")
        setStyles(textField: phoneNumberTextField, placeholder: "Phone Number")
        setStyles(textField: readOnlyTextField, placeholder: "Read Only")

        nameTextField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            print(message)
        }.store(in: &cancellables)
        
        phoneNumberTextField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
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

