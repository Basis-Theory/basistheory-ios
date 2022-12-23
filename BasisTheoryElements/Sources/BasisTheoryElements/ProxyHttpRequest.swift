//
//  ProxyHttpRequest.swift
//  
//
//  Created by Brian Gonzalez on 12/21/22.
//

import Foundation

public struct ProxyHttpRequest {
    public var method: HttpMethod?
    public var path: String?
    public var query: [String:String]?
    public var body: [String:Any]?
    public var headers: [String:String]?
    public var url: String?
    
    public init(url: String? = nil, method: HttpMethod? = .get, path: String? = nil, query: [String : String]? = nil, body: [String : Any]? = nil, headers: [String : String]? = nil) {
        self.url = url
        self.method = method
        self.path = path
        self.query = query
        self.body = body
        self.headers = headers
    }
}
