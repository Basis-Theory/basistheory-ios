//
//  BasisTheoryUIViewController.swift
//  
//
//  Created by Brian Gonzalez on 5/5/23.
//

import UIKit

open class BasisTheoryUIViewController: UIViewController, UITextFieldDelegate {
    public func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return true;
    }
}

