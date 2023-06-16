//
//  HttpClientHelpers.swift
//  
//
//  Created by Brian Gonzalez on 6/16/23.
//

import Foundation

public struct Config {
    var headers: [String: String]
}

struct HttpClientHelpers {
    static func executeRequest(method: HttpMethod, url: String, payload: [String: Any]?, config: Config?, completion: @escaping ((_ request: URLResponse?, _ data: Any?, _ error: Error?) -> Void)) -> Void {
        guard let url = URL(string: url) else {
            completion(nil, nil, HttpClientError.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let payload = payload {
            let httpBody = try! JSONSerialization.data(withJSONObject: payload, options: [])
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
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        
                        TelemtryLogging.info("Successful \(method) response from \(url)")
                        completion(response, json, nil)
                    } catch {
                        TelemtryLogging.warn("Unsuccessful \(method) response from \(url)", error: error)
                        completion(response, nil, error)
                    }
                } else {
                    TelemtryLogging.warn("Unexpected \(method) response from \(url): response does not have a body", error: error)
                    completion(response, nil, error)
                }
            } else {
                TelemtryLogging.warn("Invalid \(method) request to \(url)", error: error)
                completion(nil, nil, HttpClientError.invalidRequest)
            }
        }
        
        task.resume()
    }
}
