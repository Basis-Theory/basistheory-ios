//
//  ProxyHelpers.swift
//  
//
//  Created by Brian Gonzalez on 12/21/22.
//

import Foundation
import BasisTheory

struct ProxyHelpers {
    static func getUrlRequest(proxyHttpRequest: ProxyHttpRequest?) throws -> URLRequest {
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
        
        let Url = String(format: url)
        
        guard let serviceUrl = URL(string: Url) else {
            // TODO: reconsider error thrown here
            throw TokenizingError.invalidInput
        }
        
        return URLRequest(url: serviceUrl)
    }
    
    static func setMethodOnRequest(proxyHttpRequest: ProxyHttpRequest?, request: inout URLRequest) {
        request.httpMethod = proxyHttpRequest?.method.rawValue ?? HttpMethod.get.rawValue
    }
    
    static func setHeadersOnRequest(apiKey: String?, proxyKey: String?, proxyUrl: String?, proxyHttpRequest: ProxyHttpRequest?, request: inout URLRequest) {
        var modifiedHeaders = proxyHttpRequest?.headers ?? [:]
        modifiedHeaders["Content-Type"] = "Application/json"
        
        if apiKey != nil {
            modifiedHeaders["BT-API-KEY"] = apiKey
        } else {
            modifiedHeaders.removeValue(forKey: "BT-API-KEY")
        }
        
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
    }
    
    static func setBodyOnRequest(proxyHttpRequest: ProxyHttpRequest?, request: inout URLRequest) {
        // TODO: test empty body request. don't throw if one is not provided
        guard let httpBody = try? JSONSerialization.data(withJSONObject: proxyHttpRequest?.body, options: []) else {
            return
        }
        request.httpBody = httpBody
    }
    
    private static func traverseJson(dictionary: [String: Any], json: inout JSON) {
        for (key, value) in dictionary {
            if let value = value as? [String: Any] {
                json[key] = JSON.dictionaryValue([:])
                
                traverseJson(dictionary: value, json: &json[key]!)
            } else {
                json[key] = JSON.elementValueReference(ElementValueReference(valueMethod: {
                    String(describing: value)
                }, isValid: true))
            }
        }
    }
    
    static func executeRequest(request: URLRequest, completion: @escaping ((_ request: URLResponse?, _ data: JSON?, _ error: Error?) -> Void)) {
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let serializedJson = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    var json = JSON.dictionaryValue([:])
                    traverseJson(dictionary: serializedJson as! [String:Any], json: &json)
                    
                    completion(response, json, nil)
                } catch {
                    completion(response, nil, error)
                }
            }
        }.resume()
    }
}
