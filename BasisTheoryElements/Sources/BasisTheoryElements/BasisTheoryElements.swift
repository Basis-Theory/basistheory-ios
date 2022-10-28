//
//  BasisTheoryElements.swift
//
//
//  Created by Brian Gonzalez on 10/13/22.
//

import Foundation
import BasisTheory
import AnyCodable
import Combine

final public class BasisTheoryElements {
    public static var apiKey: String = ""

    public static func tokenize(body: [String: Any], apiKey: String, completion: @escaping ((_ data: AnyCodable?, _ error: Error?) -> Void)) -> Void {
        var mutableBody = body
        replaceElementRefs(body: &mutableBody)

        let apiKeyForTokenize = !BasisTheoryElements.apiKey.isEmpty ? BasisTheoryElements.apiKey : apiKey

        TokenizeAPI.tokenizeWithRequestBuilder(body: AnyCodable(mutableBody)).addHeader(name: "BT-API-KEY", value: apiKeyForTokenize).execute { result in
            do {
                let app = try result.get()

                completion(app.body, nil)
            } catch {
                print(error)
            }
        }
    }

    private static func replaceElementRefs(body: inout [String: Any]) -> Void {
        for (key, val) in body {
            if var v = val as? [String: Any] {
                replaceElementRefs(body: &v)
                body[key] = v
            } else if let v = val as? TextElementUITextField {
                body[key] = v.getValue()
            }
        }
    }
}

