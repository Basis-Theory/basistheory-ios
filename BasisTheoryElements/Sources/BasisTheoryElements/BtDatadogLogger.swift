//
//  BtLogger.swift
//  
//
//  Created by kevin on 30/8/23.
//

import Foundation

internal class BtDatadogLogger {
    internal var attrMap: [String: Any] = [:]
    private var clientToken: String
    private var logURL: URL = URL(string: "https://http-intake.logs.datadoghq.com/v1/input/")!
    
    init(clientToken: String) {
        self.clientToken = clientToken
    }
    
    static func builder() -> BTDatadogLoggerBuilder {
        return BTDatadogLoggerBuilder()
    }
    
    func log(message: String, level: String, error: Error?, attributes: [String: Encodable]?) {
        if let attributes = attributes {
            attrMap.merge(attributes) { _, new in new }
        }
        
        if level == "error", let error = error {
            attrMap["message"] = "\(message): \(error.localizedDescription)"
        } else {
            attrMap["message"] = message
        }
        
        attrMap["level"] = level
        
        pushLogEventToRemote()
        
        attrMap.removeAll()
    }
    
    internal func addAttribute(key forKey: String, value: String) {
        attrMap[forKey] = value
    }
    
    private func pushLogEventToRemote() {
        var request = URLRequest(url: logURL.appendingPathComponent(clientToken))
        request.httpMethod = "POST"
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: attrMap) {
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // Handle error and response if needed
            }
            
            task.resume()
        }
    }
}

internal class BTDatadogLoggerBuilder {
    private var clientToken: String?
    private var attributes: [String: String] = [:]
    
    func withClientToken(_ clientToken: String) -> Self {
        self.clientToken = clientToken
        
        return self
    }
    
    func withAttribute(key forKey: String, value: String) -> Self {
        attributes[forKey] = value
        
        return self
    }
    
    func build() -> BtDatadogLogger {
        let logger = BtDatadogLogger(clientToken: clientToken!)
        logger.attrMap.merge(attributes) { _, new in new }
        attributes.removeAll()
        
        return logger
    }
}
