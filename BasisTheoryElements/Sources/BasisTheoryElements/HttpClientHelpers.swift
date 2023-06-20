//
//  HttpClientHelpers.swift
//  
//
//  Created by Brian Gonzalez on 6/16/23.
//

import Foundation

public struct Config {
    public var headers: [String: String]
    
    public init(headers: [String: String]) {
        self.headers = headers
    }
}

struct HttpClientHelpers {
    static func executeRequest(method: HttpMethod, url: String, payload: [String: Any]?, config: Config?, completion: @escaping ((_ request: URLResponse?, _ data: JSON?, _ error: Error?) -> Void)) -> Void {
        guard let url = URL(string: url) else {
            completion(nil, nil, HttpClientError.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let payload = payload {
            var mutablePayload = payload
            do {
                try BasisTheoryElements.replaceElementRefs(body: &(mutablePayload), endpoint: url.absoluteString)
            } catch {
                completion(nil, nil, HttpClientError.invalidRequest) // error logged with more detail in replaceElementRefs
                return
            }
            
            let httpBody = try! JSONSerialization.data(withJSONObject: mutablePayload, options: [])
            request.httpBody = httpBody
        }
        
        if let config = config {
            for header in config.headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                if let data = data {
                    do {
                        let serializedJson = try JSONSerialization.jsonObject(with: data, options: [])
                        
                        var json = JSON.dictionaryValue([:])
                        BasisTheoryElements.traverseJsonDictionary(dictionary: serializedJson as! [String:Any], json: &json, transformValue: JSON.rawValue)
                        
                        TelemetryLogging.info("Successful \(method) response from \(url)")
                        completion(response, json, nil)
                    } catch {
                        TelemetryLogging.warn("Unsuccessful \(method) response from \(url)", error: error)
                        completion(response, nil, error)
                    }
                } else {
                    TelemetryLogging.warn("Unexpected \(method) response from \(url): response does not have a body", error: error)
                    completion(response, nil, error)
                }
            } else {
                TelemetryLogging.warn("Invalid \(method) request to \(url)", error: error)
                completion(nil, nil, HttpClientError.invalidRequest)
            }
        }
        
        task.resume()
    }
}
