//
//  Configuration.swift
//  IntegrationTester
//
//  Created by Brian Gonzalez on 10/19/22.
//

import Foundation

struct EnvConfig: Decodable {
    let btApiKey: String?
    
    init() {
        self.btApiKey = nil
    }
}

class Configuration {
    static public func getConfiguration() -> EnvConfig {
        let resource = ProcessInfo.processInfo.environment["CI"] == "1" ? "Env.CI" : "Env.Local"

        do {
            let url = Bundle(for: Configuration.self).path(forResource: resource, ofType: "plist")!
            let data = FileManager.default.contents(atPath: url)!
            
            return try PropertyListDecoder().decode(EnvConfig.self, from: data)
        } catch {
            print(error)
        }
        
        return EnvConfig()
    }
}
