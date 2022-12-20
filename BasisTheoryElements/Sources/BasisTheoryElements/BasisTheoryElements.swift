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

@dynamicMemberLookup
struct Person {
    subscript(dynamicMember member: String) -> String {
        let properties = ["name": "Taylor Swift", "city": "Nashville"]
        return properties[member, default: ""]
    }
}

@dynamicMemberLookup
enum JSON {
    case elementValueReference(ElementValueReference)
//    case intValue(Int)
//    case stringValue(String)
    case arrayValue(Array<JSON>)
    case dictionaryValue(Dictionary<String, JSON>)
    
    var elementValueReference: ElementValueReference? {
      if case .elementValueReference(let elementValueRef) = self {
         return elementValueRef
      }
      return nil
   }
    
    subscript(index: Int) -> JSON? {
        if case .arrayValue(let arr) = self {
            return index < arr.count ? arr[index] : nil
        }
        return nil
    }
    
    subscript(key: String) -> JSON? {
        if case .dictionaryValue(let dict) = self {
            return dict[key]
        }
        return nil
    }
    
    subscript(dynamicMember member: String) -> JSON? {
        if case .dictionaryValue(let dict) = self {
            return dict[member]
        }
        return nil
    }
}

public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    case head = "HEAD"
    case options = "OPTIONS"
    case connect = "CONNECT"
    case query = "QUERY"
    case trace = "TRACE"
}

public struct ProxyHttpRequest {
    public var method: HttpMethod = .get
    public var path: String? = nil
    public var query: [String:String]? = nil
    public var body: [String:Any]? = nil
    public var headers: [String:String]? = nil
    public var url: String? = nil
    
    public init(url: String? = nil, method: HttpMethod, path: String? = nil, query: [String : String]? = nil, body: [String : Any]? = nil, headers: [String : String]? = nil) {
        self.url = url
        self.method = method
        self.path = path
        self.query = query
        self.body = body
        self.headers = headers
    }
}

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
    
    private func walkJson(dictionary: [String: Any], body: inout JSON?) {
        for (key, value) in dictionary {
            print("\(key): \(value)")
            if let value = value as? [String: Any] {
                var nilThing: JSON? = nil
                walkJson(dictionary: value, body: &nilThing)
            }
        }
    }
    
    // TODO: consider moving into a different module
    public static func proxy(apiKey: String, proxyKey: String? = nil, proxyUrl: String? = nil, proxyHttpRequest: ProxyHttpRequest? = nil, completion: @escaping ((_ request: URLResponse?, _ data: ElementValueReference?, _ error: Error?) -> Void)) -> Void {
        BasisTheoryAPI.basePath = basePath
        var url = proxyHttpRequest?.url ?? "\(BasisTheoryAPI.basePath)/proxy"
        
        if proxyHttpRequest?.path != nil {
            url += proxyHttpRequest!.path!
        }
        
        var modifiedQuery = proxyHttpRequest?.query ?? [:]
        modifiedQuery.removeValue(forKey: "bt-proxy-key")
        
        let urlQueryParams = modifiedQuery.compactMap({(key, value) -> String in
            return "\(key)=\(value)"
        }).joined(separator: "&")
        
        if !urlQueryParams.isEmpty {
            url += "?\(urlQueryParams)"
        }
        
        getApplicationKey(apiKey: getApiKey(apiKey)) {data, error in
            guard error == nil else {
                completion(nil, nil, error)
                return
            }

            guard data?.type == "expiring" else {
                completion(nil, nil, TokenizingError.applicationTypeNotExpiring)
                return
            }
        }
        
        let Url = String(format: url)
        
        guard let serviceUrl = URL(string: Url) else {
            // TODO: throw here
            return
        }
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = proxyHttpRequest?.method.rawValue ?? HttpMethod.get.rawValue
        
        var modifiedHeaders = proxyHttpRequest?.headers ?? [:]
        modifiedHeaders["BT-API-KEY"] = apiKey
        modifiedHeaders["Content-Type"] = "Application/json"
        
        if proxyKey != nil {
            modifiedHeaders["BT-PROXY-KEY"] = proxyKey
            modifiedHeaders.removeValue(forKey: "BT-PROXY-URL")
        } else if proxyUrl != nil {
            modifiedHeaders["BT-PROXY-URL"] = proxyUrl
            modifiedHeaders.removeValue(forKey: "BT-PROXY-KEY")
        }
        
        for header in modifiedHeaders {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        // TODO: test empty body request. don't throw if one is not provided
        guard let httpBody = try? JSONSerialization.data(withJSONObject: proxyHttpRequest?.body, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    // TODO: return data in an irratrievable struct var but allow way to traverse JSON object
                    print("data: \(data)")
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
//                    let json = try! JSONDecoder().decode(JSON.self, from: data)
                    
                    let j = JSON.dictionaryValue([
//                        "comment": .stringValue("Not being able to tell the difference at call site is confusing"),
//                        "count": .intValue(42),
//                        "count2": .intValue(1337)
                        "comment": .elementValueReference(ElementValueReference(valueMethod: {
                            "hiddenValue"
                        }, isValid: true))
                    ])
                    
                    let test = ElementValueReference(valueMethod: {
                        "hiddenValue"
                    }, isValid: true)
                    
                    print(test.getValue())
                    
                    print(j.comment?.elementValueReference?.getValue())
//                    print(j.comment!.getValue())
                    
                    let dynamic = JSON.dictionaryValue(json as! Dictionary<String, JSON>)
                    print("dynamic: \(dynamic)")
                    print("json: \(json)")
                    let elementValueReference = ElementValueReference(valueMethod: {
                        String(describing: json)
                    }, isValid: true)
                    
                    print("valueMethodResponse: \(elementValueReference.getValue())")
                    completion(response, elementValueReference, nil)
                } catch {
                    completion(response, nil, error)
                }
            }
        }.resume()
    }
    
    private static func replaceElementRefs(body: inout [String: Any]) throws -> Void {
        for (key, val) in body {
            if var v = val as? [String: Any] {
                try replaceElementRefs(body: &v)
                body[key] = v
            } else if let v = val as? ElementReferenceProtocol {
                let textValue = v.getValue()
                
                if !v.isValid! {
                    throw TokenizingError.invalidInput
                }
                body[key] = textValue
            }
        }
    }
}

