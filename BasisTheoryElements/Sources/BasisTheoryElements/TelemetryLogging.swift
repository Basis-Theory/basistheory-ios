//
//  TelemetryLogging.swift
//  
//
//  Created by Brian Gonzalez on 3/6/23.
//

@_implementationOnly import Datadog
import UIKit

struct TelemtryLogging {
    private static var hasInitialized = false
    private static var logger: Logger? = nil
    
    private static func initLogger() -> Void {
        if !hasInitialized {
            let env = Bundle.main.bundleIdentifier?.contains("IntegrationTester") ?? false ? "local" : "prod"
            
            Datadog.initialize(
                appContext: .init(),
                trackingConsent: .granted,
                configuration: Datadog.Configuration
                    .builderUsing(clientToken: "pubfbd371e5695e9b44b66a4940f0e8d2ac", environment: env)
                    .set(serviceName: "BasisTheory iOS Elements")
                    .set(endpoint: .us1)
                    .build()
            )
            
            logger = Logger.builder
                .sendNetworkInfo(true)
                .set(datadogReportingThreshold: .info)
                .build()
            
            logger!.addAttribute(forKey: "env", value: env)
            logger!.addAttribute(forKey: "application", value: "BasisTheory iOS Elements")
            logger!.addAttribute(forKey: "vendorId", value: UIDevice.current.identifierForVendor?.uuidString ?? "Unknown vendorId")
            logger!.addAttribute(forKey: "bundleId", value: Bundle.main.bundleIdentifier ?? "Unknown vendor")
            logger!.addAttribute(forKey: "device", value: UIDevice.current.name)
            logger!.addAttribute(forKey: "btElementsVersion", value: BasisTheoryElements.version)
        }
        
        hasInitialized = true
    }
    
    static func info(_ message: String, error: Error? = nil, attributes: [String: Encodable]? = nil) {
        initLogger()
        logger!.info(message, error: error, attributes: attributes)
    }
    
    static func warn(_ message: String, error: Error? = nil, attributes: [String: Encodable]? = nil) {
        initLogger()
        logger!.warn(message, error: error, attributes: attributes)
    }
    
    static func error(_ message: String, error: Error? = nil, attributes: [String: Encodable]? = nil) {
        initLogger()
        logger!.error(message, error: error, attributes: attributes)
    }
}
