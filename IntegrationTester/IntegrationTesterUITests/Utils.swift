//
//  Utils.swift
//  IntegrationTesterUITests
//
//  Created by Brian Gonzalez on 11/2/22.
//

import Foundation
import BasisTheory

func convertStringToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error)
        }
    }
    
    return nil
}
