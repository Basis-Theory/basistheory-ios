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
import Alamofire

public enum TokenizingError: Error {
    case applicationTypeNotPublic
    case applicationTypeNotExpiring
    case invalidInput
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
        ApplicationsAPI.getByKeyWithRequestBuilder().addHeader(name: "User-Agent", value: "BasisTheory iOS Elements").addHeader(name: "BT-API-KEY", value: getApiKey(apiKey)).execute { result in
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
            
            TokenizeAPI.tokenizeWithRequestBuilder(body: AnyCodable(mutableBody)).addHeader(name: "BT-API-KEY", value: getApiKey(apiKey)).execute { result in
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
            
            TokensAPI.createWithRequestBuilder(createTokenRequest: createTokenRequest).addHeader(name: "User-Agent", value: "BasisTheory iOS Elements").addHeader(name: "BT-API-KEY", value: getApiKey(apiKey)).execute { result in
                completeApiRequest(result: result, completion: completion)
            }
        }
    }
    
    public static func proxy(apiKey: String, proxyKey: String, method: Alamofire.HTTPMethod = .get, query: [String:String]? = nil, body: [String:Any]? = nil, headers: HTTPHeaders? = nil, completion: @escaping ((_ data: AnyCodable?, _ error: Error?) -> Void)) -> Void {
        BasisTheoryAPI.basePath = basePath
        var url = "\(BasisTheoryAPI.basePath)/proxy"
        
        var modifiedQuery = query ?? [:]
        modifiedQuery.removeValue(forKey: "bt-proxy-key")
        
        let urlQueryParams = modifiedQuery.compactMap({(key, value) -> String in
            return "\(key)=\(value)"
        }).joined(separator: "&")
        
        if !urlQueryParams.isEmpty {
            url += "?\(urlQueryParams)"
        }
        
        getApplicationKey(apiKey: getApiKey(apiKey)) {data, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard data?.type == "expiring" else {
                completion(nil, TokenizingError.applicationTypeNotExpiring)
                return
            }
        }
        
        var modifiedHeaders = headers ?? [:]
        modifiedHeaders["BT-API-KEY"] = apiKey
        modifiedHeaders["BT-PROXY-KEY"] = apiKey
        
        AF.request(url, method: method, parameters: body, encoding: JSONEncoding.default, headers: headers).responseData { response in
            // TODO: return ElementValueReference instance here
            
            let stringifiedData = try! JSONSerialization.jsonObject(with: response.data!, options: []) as? [String : Any]
            
            debugPrint("Response error: \(response.error)")
            debugPrint("Response data: \(response.data)")
            debugPrint("Response stringifiedData: \(stringifiedData)")
            debugPrint("Response response: \(response.response)")
            
//            completion(response.data, nil)
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

