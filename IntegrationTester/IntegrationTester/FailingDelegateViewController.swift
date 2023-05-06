//
//  FailingDelegateViewController.swift
//  IntegrationTester
//
//  Created by Brian Gonzalez on 5/5/23.
//

import UIKit
import BasisTheoryElements

class FailingDelegateViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameTextField: TextElementUITextField!
    @IBOutlet weak var successSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.placeholder = "Name"
        nameTextField.delegate = self
        successSwitch.isOn = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        successSwitch.isOn = true
        self.view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(string)
        
        return true
    }
}
