//
//  TelemetryLogging.swift
//  
//
//  Created by Brian Gonzalez on 3/6/23.
//

import Datadog
import UIKit

struct TelemtryLogging {
    private static var hasInitialized = false
    private static var logger: Logger? = nil
    
    private static func initLogger() -> Void {
        if !hasInitialized {
            let env = BasisTheoryElements.basePath.contains("dev") ? "local" : "prod"
            
            Datadog.initialize(
                appContext: .init(),
                trackingConsent: .granted, // TODO: dig into GDPR further
                configuration: Datadog.Configuration
                    .builderUsing(clientToken: "pubfbd371e5695e9b44b66a4940f0e8d2ac", environment: env)
                    .set(serviceName: "BasisTheory iOS Elements")
                    .set(endpoint: .us1) // TODO: decide on this param
                    .build()
            )
            
            logger = Logger.builder
                .sendNetworkInfo(true)
                .set(datadogReportingThreshold: .info)
                .build()
            
            logger!.addAttribute(forKey: "application", value: "BasisTheory iOS Elements")
            logger!.addAttribute(forKey: "vendorId", value: UIDevice.current.identifierForVendor?.uuidString ?? UUID(uuid: UUID_NULL).uuidString)
            logger!.addAttribute(forKey: "bundleId", value: Bundle.main.bundleIdentifier ?? "Unknown Vendor")
            logger!.addAttribute(forKey: "device", value: UIDevice.current.name)
            logger!.addAttribute(forKey: "btElementsVersion", value: BasisTheoryElements.version)
        }
        
        hasInitialized = true
    }
    
    // TODO: add attributes to logs
    // error and type of error (log all validation and details)
    // success
    // sanitized payload
    // trace id
    // every API call
    // loading of element on screen
    // state of element
    // timing of API calls
    
    // TODO: investigate console errors
    
    static func info(_ message: String, attributes: [String: String]? = nil) {
        initLogger()
        logger!.info(message, attributes: attributes)
    }
    
    static func error(_ message: String, error: Error? = nil, attributes: [String: String]? = nil) {
        initLogger()
        logger!.error(message, error: error, attributes: attributes)
    }
}
