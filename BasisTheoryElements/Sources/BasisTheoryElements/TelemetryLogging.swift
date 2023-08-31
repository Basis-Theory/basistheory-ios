//
//  TelemetryLogging.swift
//
//
//  Created by Brian Gonzalez on 3/6/23.
//

import UIKit

struct TelemetryLogging {
    private static var hasInitialized = false
    
    private static var logger: BtDatadogLogger = BtDatadogLogger.builder()
            .withClientToken("pubfbd371e5695e9b44b66a4940f0e8d2ac")
            .withAttribute(key: "env", value: Bundle.main.bundleIdentifier?.contains("IntegrationTester") ?? false ? "local" : "prod")
            .withAttribute(key: "application", value: "BasisTheory iOS Elements")
            .withAttribute(key: "service",  value: "BasisTheory iOS Elements")
            .withAttribute(key: "vendorId",  value: UIDevice.current.identifierForVendor?.uuidString ?? "Unknown vendorId")
            .withAttribute(key: "bundleId", value: Bundle.main.bundleIdentifier ?? "Unknown vendor")
            .withAttribute(key: "bundleVersion", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown vendor version")
            .withAttribute(key: "bundleBuildVersion", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown vendor build version")
            .withAttribute(key: "device", value: UIDevice.current.name)
            .withAttribute(key: "btElementsVersion", value: BasisTheoryElements.version)
            .build()
        
    static func info(_ message: String, error: Error? = nil, attributes: [String: Encodable]? = nil) {
        logger.log(message: message, level: "info", error: error, attributes: attributes)
    }
    
    static func warn(_ message: String, error: Error? = nil, attributes: [String: Encodable]? = nil) {
        logger.log(message: message, level: "warn", error: error, attributes: attributes)
    }
    
    static func error(_ message: String, error: Error? = nil, attributes: [String: Encodable]? = nil) {
        logger.log(message: message, level: "error", error: error, attributes: attributes)
    }
}
