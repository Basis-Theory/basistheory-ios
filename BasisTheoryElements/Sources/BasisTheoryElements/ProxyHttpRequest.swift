//
//  ProxyHttpRequest.swift
//  
//
//  Created by Brian Gonzalez on 12/21/22.
//

import Foundation

public struct ProxyHttpRequest {
    public var method: HttpMethod = .get
    public var path: String? = nil
    public var query: [String:String]? = nil
    public var body: [String:Any]? = nil
    public var headers: [String:String]? = nil
    public var url: String? = nil
    
    public init(url: String? = nil, method: HttpMethod, path: String? = nil, query: [String : String]? = nil, body: [String : Any]? = nil, headers: [String : String]? = nil) {
        self.url = url
        self.method = method
        self.path = path
        self.query = query
        self.body = body
        self.headers = headers
    }
}
