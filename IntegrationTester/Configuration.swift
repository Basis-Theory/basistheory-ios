//
//  Configuration.swift
//  IntegrationTester
//
//  Created by Brian Gonzalez on 10/19/22.
//

import Foundation

struct EnvConfig: Decodable {
    let btApiKey: String?
    let privateBtApiKey: String?
    let proxyKey: String?
    let proxyKeyNoAuth: String?
    let privateProdBtApiKey: String?
    let prodBtApiKey: String?
    
    init() {
        self.btApiKey = nil
        self.privateBtApiKey = nil
        self.proxyKey = nil
        self.proxyKeyNoAuth = nil
        self.privateProdBtApiKey = nil
        self.prodBtApiKey = nil
    }
}

extension String: Error {}

class Configuration {
    static public func getConfiguration() -> EnvConfig {
        do {
            let url = Bundle(for: Configuration.self).path(forResource: "Env", ofType: "plist")!
            let data = FileManager.default.contents(atPath: url)!
            
            return try PropertyListDecoder().decode(EnvConfig.self, from: data)
        } catch {
            print(error)
        }
        
        return EnvConfig()
    }
}
