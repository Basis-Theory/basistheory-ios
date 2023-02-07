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
        var url = proxyHttpRequest?.url ?? "\(BasisTheoryElements.basePath)/proxy"
        
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
        
        let serviceUrl = URL(string: url)!
        
        return URLRequest(url: serviceUrl)
    }
    
    static func setMethodOnRequest(proxyHttpRequest: ProxyHttpRequest?, request: inout URLRequest) {
        request.httpMethod = proxyHttpRequest?.method?.rawValue ?? HttpMethod.get.rawValue
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
        if let proxyHttpRequestBody = proxyHttpRequest?.body {
            let httpBody = try! JSONSerialization.data(withJSONObject: proxyHttpRequestBody, options: [])
            request.httpBody = httpBody
        }
    }
    
    static func executeRequest(request: URLRequest, completion: @escaping ((_ request: URLResponse?, _ data: JSON?, _ error: Error?) -> Void)) {
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response {
                if let data = data {
                    do {
                        let serializedJson = try JSONSerialization.jsonObject(with: data, options: [])
                        
                        var json = JSON.dictionaryValue([:])
                        BasisTheoryElements.traverseJsonDictionary(dictionary: serializedJson as! [String:Any], json: &json)
                        
                        completion(response, json, nil)
                    } catch {
                        completion(response, nil, error)
                    }
                } else {
                    completion(response, nil, error)
                }
            } else {
                completion(nil, nil, ProxyError.invalidRequest)
            }
        }.resume()
    }
}
