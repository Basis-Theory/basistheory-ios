//
//  ElementTransform.swift
//  
//
//  Created by Amber Torres on 11/22/22.
//

import Foundation

public struct ElementTransform {
    public var matcher: NSRegularExpression
    public var stringReplacement: String?
    
    public init(matcher: NSRegularExpression, stringReplacement: String? = "") {
        self.matcher = matcher
        self.stringReplacement = stringReplacement
    }
}
