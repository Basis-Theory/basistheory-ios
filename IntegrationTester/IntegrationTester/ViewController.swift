//
//  ViewController.swift
//  IntegrationTester
//
//  Created by Brian Gonzalez on 10/18/22.
//

import UIKit
import Combine
import BasisTheory

class ViewController: UIViewController {
    private let lightBackgroundColor : UIColor = UIColor( red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0 )
    private let darkBackgroundColor : UIColor = UIColor( red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0 )
    private var cancellables = Set<AnyCancellable>()

    @IBOutlet private weak var nameTextField: TextElementUITextField!
    @IBOutlet private weak var phoneTextField: TextElementUITextField!
    
    @IBAction func printToConsoleLog(_ sender: Any) {
        nameTextField.text = "Tom Cruise"
        phoneTextField.text = "555-123-4567"
        
        print("nameTextField.text: \(nameTextField.text)")
        print("phoneTextField.text: \(phoneTextField.text)")
    }
    
    @IBAction func tokenize(_ sender: Any) {
        let body: [String: Any] = [
            "data": [
                "name": self.nameTextField,
                "phoneNumber": self.phoneTextField,
                "myProp": "myValue"
            ],
            "search_indexes": ["{{ data.phoneNumber }}"],
            "type": "token"
        ]

        // TODO: insert API key from somewhere else
        let config = Configuration.getConfiguration()
        print(config)
        BasisTheoryElements.tokenize(body: body, apiKey: config.btApiKey!) { data, error in
            print(data)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setStyles(textField: nameTextField, placeholder: "Name")
        setStyles(textField: phoneTextField, placeholder: "Phone Number")

        nameTextField.subject.sink { completion in
            print(completion)
        } receiveValue: { message in
            print(message)
        }.store(in: &cancellables)
    }
    
    private func setStyles(textField: TextElementUITextField, placeholder: String) {
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

