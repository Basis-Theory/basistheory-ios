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
    
    @IBOutlet weak var cvcTextField: CardVerificationCodeElementUITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setStyles(textField: cvcTextField, placeholder: "CVC")
        
        cvcTextField.subject.sink { completion in
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
