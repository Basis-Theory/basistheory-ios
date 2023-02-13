//
//  CardRevealViewController.swift
//  IntegrationTester
//
//  Created by Brian Gonzalez on 1/24/23.
//

import Foundation
import UIKit
import BasisTheoryElements
import BasisTheory

class CardRevealViewController: UIViewController {
    @IBOutlet weak var cvcTextField: CardVerificationCodeUITextField!
    @IBOutlet weak var cardExpirationDateTextField: CardExpirationDateUITextField!
    @IBOutlet weak var cardNumberTextField: CardNumberUITextField!
    
    @IBAction func retrieveCard(_ sender: Any) {
        BasisTheoryElements.basePath = "https://api.basistheory.com"
        
        let prodBtApiKey = Configuration.getConfiguration().prodBtApiKey!
        BasisTheoryElements.createSession(apiKey: prodBtApiKey) { data, error in
            let sessionApiKey = data!.sessionKey!
            let nonce = data!.nonce!

            // AUTHORIZING A SESSION SHOULD HAPPEN ON THE BACKEND
            let privateProdBtApiKey = Configuration.getConfiguration().privateProdBtApiKey!
            let btCardTokenId = "a568dd92-c48c-4221-8ce4-a0be9cbfa927"
            let rule = AccessRule(description: "GetTokenById iOS Test", priority: 1, transform: "reveal", conditions: [Condition(attribute: "id", _operator: "equals", value: btCardTokenId)], permissions: ["token:read", "token:use"])
            SessionsAPI.authorizeWithRequestBuilder(authorizeSessionRequest: AuthorizeSessionRequest(nonce: nonce, rules: [rule])).addHeader(name: "BT-API-KEY", value: privateProdBtApiKey).execute { result in
                try! result.get().body
                
                let lithicCardTokenPath = "/b9e07ec5-5220-4500-9e71-e788fcb1084e"
                let proxyKey = "BnBccfKBidARBiycsnoDQW"
                let proxyHttpRequest = ProxyHttpRequest(method: .get, path: lithicCardTokenPath)
                BasisTheoryElements.proxy(
                    apiKey: sessionApiKey,
                    proxyKey: proxyKey,
                    proxyHttpRequest: proxyHttpRequest)
                { response, data, error in
                    self.cvcTextField.setValue(elementValueReference: data!.cvv!.elementValueReference)
                    
                    BasisTheoryElements.getTokenById(id: btCardTokenId, apiKey: sessionApiKey) { data, error in
                        self.cardNumberTextField.setValue(elementValueReference: data!.data!.number!.elementValueReference)
                        self.cardExpirationDateTextField.setValue(month: data!.data!.expiration_month!.elementValueReference, year: data!.data!.expiration_year!.elementValueReference)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
