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

public enum TokenizingError: Error {
    case applicationNotPublic
}

final public class BasisTheoryElements {
    public static var apiKey: String = ""
    public static var basePath: String = "https://api.basistheory.com"
    
    private static func getApiKey(_ apiKey: String?) -> String {
        !BasisTheoryElements.apiKey.isEmpty ? BasisTheoryElements.apiKey : apiKey!
    }
    
    private static func completeApiRequest<T>(result: Result<Response<T>, ErrorResponse>, completion: @escaping ((_ data: T?, _ error: Error?) -> Void)) {
        do {
            let app = try result.get()

            completion(app.body, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    private static func getApplicationKey(apiKey: String, completion: @escaping ((_ data: Application?, _ error: Error?) -> Void)) {
        BasisTheoryAPI.basePath = basePath
        ApplicationsAPI.getByKeyWithRequestBuilder().addHeader(name: "BT-API-KEY", value: getApiKey(apiKey)).execute { result in
            completeApiRequest(result: result, completion: completion)
        }
    }

    public static func tokenize(body: [String: Any], apiKey: String, completion: @escaping ((_ data: AnyCodable?, _ error: Error?) -> Void)) -> Void {
        var mutableBody = body
        replaceElementRefs(body: &mutableBody)

        BasisTheoryAPI.basePath = basePath
        getApplicationKey(apiKey: getApiKey(apiKey)) { data, error in
            guard data?.type == "public" else {
                completion(nil, TokenizingError.applicationNotPublic)
                return
            }
            
            TokenizeAPI.tokenizeWithRequestBuilder(body: AnyCodable(mutableBody)).addHeader(name: "BT-API-KEY", value: getApiKey(apiKey)).execute { result in
                completeApiRequest(result: result, completion: completion)
            }
        }
    }
    
    public static func createToken(body: CreateTokenRequest, apiKey: String, completion: @escaping ((_ data: CreateTokenResponse?, _ error: Error?) -> Void)) -> Void {
        var mutableBody = body
        var mutableData = (body.data?.value as! [[String: Any]]).first
        
        if var mutableData = mutableData {
            replaceElementRefs(body: (&mutableData)! )
        }

        mutableBody.data = AnyCodable(mutableData)

        let apiKeyForTokenize = !BasisTheoryElements.apiKey.isEmpty ? BasisTheoryElements.apiKey : apiKey
        
        BasisTheoryAPI.basePath = basePath

        getApplicationKey(apiKey: getApiKey(apiKey)) {data, error in
             guard data?.type == "public" else {
                completion(nil, TokenizingError.applicationNotPublic)
                return
             }
            
            TokensAPI.createWithRequestBuilder(createTokenRequest: mutableBody).addHeader(name: "BT-API-KEY", value: apiKeyForTokenize).execute { result in
                completeApiRequest(result: result, completion: completion)
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

