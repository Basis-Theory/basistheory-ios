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
    case applicationTypeNotPublic
    case invalidInput
}

public enum ProxyError: Error {
    case invalidRequest
}

extension RequestBuilder {
    func addBasisTheoryElementHeaders(apiKey: String) -> Self {
        addHeaders([
            "User-Agent": "BasisTheory iOS Elements",
            "BT-API-KEY": apiKey,
        ])
        
        return self
    }
}

final public class BasisTheoryElements {
    public static var apiKey: String = ""
    public static var basePath: String = "https://api.basistheory.com"
    
    private static func getApiKey(_ apiKey: String?) -> String {
        apiKey != nil ? apiKey! : BasisTheoryElements.apiKey
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
        ApplicationsAPI.getByKeyWithRequestBuilder().addBasisTheoryElementHeaders(apiKey: getApiKey(apiKey)).execute { result in
            completeApiRequest(result: result, completion: completion)
        }
    }
    
    public static func tokenize(body: [String: Any], apiKey: String? = nil, completion: @escaping ((_ data: AnyCodable?, _ error: Error?) -> Void)) -> Void {
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
                completion(nil, TokenizingError.applicationTypeNotPublic)
                return
            }
            
            TokenizeAPI.tokenizeWithRequestBuilder(body: AnyCodable(mutableBody)).addBasisTheoryElementHeaders(apiKey: getApiKey(apiKey)).execute { result in
                completeApiRequest(result: result, completion: completion)
            }
        }
    }
    
    public static func createToken(body: CreateToken, apiKey: String? = nil, completion: @escaping ((_ data: CreateTokenResponse?, _ error: Error?) -> Void)) -> Void {
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
                completion(nil, TokenizingError.applicationTypeNotPublic)
                return
            }
            
            let createTokenRequest = mutableBody.toCreateTokenRequest()
            
            TokensAPI.createWithRequestBuilder(createTokenRequest: createTokenRequest).addBasisTheoryElementHeaders(apiKey: getApiKey(apiKey)).execute { result in
                completeApiRequest(result: result, completion: completion)
            }
        }
    }
    
    public static func proxy(apiKey: String? = nil, proxyKey: String? = nil, proxyUrl: String? = nil, proxyHttpRequest: ProxyHttpRequest? = nil, completion: @escaping ((_ request: URLResponse?, _ data: JSON?, _ error: Error?) -> Void)) -> Void {
        BasisTheoryAPI.basePath = basePath
        
        var request = try! ProxyHelpers.getUrlRequest(proxyHttpRequest: proxyHttpRequest)
        
        ProxyHelpers.setMethodOnRequest(proxyHttpRequest: proxyHttpRequest, request: &request)
        
        ProxyHelpers.setHeadersOnRequest(apiKey: apiKey, proxyKey: proxyKey, proxyUrl: proxyUrl, proxyHttpRequest: proxyHttpRequest, request: &request)
        
        ProxyHelpers.setBodyOnRequest(proxyHttpRequest: proxyHttpRequest, request: &request)
        
        ProxyHelpers.executeRequest(request: request, completion: completion)
    }
    
    public static func createSession(apiKey: String? = nil, completion: @escaping ((_ data: CreateSessionResponse?, _ error: Error?) -> Void)) -> Void {
        SessionsAPI.createWithRequestBuilder().addBasisTheoryElementHeaders(apiKey: getApiKey(apiKey)).execute { result in
            completeApiRequest(result: result, completion: completion)
        }
    }
    
    private static func replaceElementRefs(body: inout [String: Any]) throws -> Void {
        for (key, val) in body {
            if var v = val as? [String: Any] {
                try replaceElementRefs(body: &v)
                body[key] = v
            } else if let v = val as? ElementReferenceProtocol {
                let textValue = v.getValue()
                
                if !v.isComplete! {
                    throw TokenizingError.invalidInput
                }
                body[key] = textValue
            }
        }
    }
}

