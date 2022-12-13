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
    case invalidInput
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
        ApplicationsAPI.getByKeyWithRequestBuilder().addHeader(name: "User-Agent", value: "BasisTheory iOS Elements").addHeader(name: "BT-API-KEY", value: getApiKey(apiKey)).execute { result in
            completeApiRequest(result: result, completion: completion)
        }
    }
    
    public static func tokenize(body: [String: Any], apiKey: String, completion: @escaping ((_ data: AnyCodable?, _ error: Error?) -> Void)) -> Void {
        var mutableBody = body
        do {
            try replaceElementRefs(body: &mutableBody)
        } catch {
            completion(nil, TokenizingError.invalidInput)
            return
        }
        
        BasisTheoryAPI.basePath = basePath
        getApplicationKey(apiKey: getApiKey(apiKey)) { data, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard data?.type == "public" else {
                completion(nil, TokenizingError.applicationNotPublic)
                return
            }
            
            TokenizeAPI.tokenizeWithRequestBuilder(body: AnyCodable(mutableBody)).addHeader(name: "BT-API-KEY", value: getApiKey(apiKey)).execute { result in
                completeApiRequest(result: result, completion: completion)
            }
        }
    }
    
    public static func createToken(body: CreateToken, apiKey: String, completion: @escaping ((_ data: CreateTokenResponse?, _ error: Error?) -> Void)) -> Void {
        var mutableBody = body
        var mutableData = body.data
        do {
            try replaceElementRefs(body: &mutableData)
        } catch {
            completion(nil, TokenizingError.invalidInput)
            return
        }
        
        mutableBody.data = mutableData
        
        BasisTheoryAPI.basePath = basePath
        getApplicationKey(apiKey: getApiKey(apiKey)) {data, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard data?.type == "public" else {
                completion(nil, TokenizingError.applicationNotPublic)
                return
            }
            
            let createTokenRequest = mutableBody.toCreateTokenRequest()
            
            TokensAPI.createWithRequestBuilder(createTokenRequest: createTokenRequest).addHeader(name: "User-Agent", value: "BasisTheory iOS Elements").addHeader(name: "BT-API-KEY", value: getApiKey(apiKey)).execute { result in
                completeApiRequest(result: result, completion: completion)
            }
        }
    }
    
    private static func replaceElementRefs(body: inout [String: Any]) throws -> Void {
        for (key, val) in body {
            if var v = val as? [String: Any] {
                try replaceElementRefs(body: &v)
                body[key] = v
            } else if let v = val as? ElementReferenceProtocol {
                var textValue = v.getValue()
                
                if !v.isValid! {
                    throw TokenizingError.invalidInput
                }
                body[key] = textValue
            }
        }
    }
}

