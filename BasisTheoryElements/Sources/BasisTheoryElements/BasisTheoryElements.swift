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

// Notes: Having a BTEncodable class that inherits from Decodable will not work since the user
// would need to convert from our element types to primitives that get returned from a create token
// response
open class BTEncodable: Decodable {
    public subscript(key: String) -> Any? {
        return asDictionary[key]
    }
    
    public var asDictionary: [String: Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
            guard let label = label else { return nil }
            
            var resultingValue = value
            
            if var btEncodeableValue = value as? BTEncodable {
                resultingValue = btEncodeableValue.asDictionary
            }
            
            return (label, resultingValue)
        }).compactMap { $0 })
        
        return dict
    }
    
    public init() {}
}

extension Dictionary {
    internal func asClass<T: Decodable>() -> T {
        // this feels pretty hacky
        let jsonData = try! JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        let decoder = JSONDecoder()
        
        return try! decoder.decode(T.self, from: jsonData)
    }
    
    internal func asClass2() {
        
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
    
    public static func tokenize<T: Decodable>(body: BTEncodable, apiKey: String? = nil, completion: @escaping ((_ data: T?, _ error: Error?) -> Void)) -> Void {
        let mutableBody = body.asDictionary
        var mutableBodyDictionary = mutableBody
        
        do {
            try replaceElementRefs(body: &mutableBodyDictionary)
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
            
            // need to set mutablebody data back to what it was
            TokenizeAPI.tokenizeWithRequestBuilder(body: AnyCodable(mutableBodyDictionary)).addBasisTheoryElementHeaders(apiKey: getApiKey(apiKey)).execute { result in
//                completeApiRequest(result: result, completion: completion)
                do {
                    let app = try result.get()
                    
                    // need to convert back to T
                    let dictionaryValue = app.body.value as! [String: Any]
                    completion(dictionaryValue.asClass(), nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
    }
    
    public static func createToken(body: CreateToken, apiKey: String? = nil, completion: @escaping ((_ data: CreateTokenResponse?, _ error: Error?) -> Void)) -> Void {
        let mutableBody = body
        var mutableData = body.data.asDictionary
        
        do {
            try replaceElementRefs(body: &mutableData)
        } catch {
            completion(nil, TokenizingError.invalidInput)
            return
        }
        
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
            
            // TODO: re-evaluate this solution
            let createTokenRequest = mutableBody.toCreateTokenRequest(data: mutableData)
            
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

