//
//  HTTPMethod.swift
//  
//
//  Created by Brian Gonzalez on 12/21/22.
//

import Foundation

public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    case head = "HEAD"
    case options = "OPTIONS"
    case connect = "CONNECT"
    case query = "QUERY"
    case trace = "TRACE"
}
