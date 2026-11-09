//
//  NetworkSession.swift
//  news-app
//
//  Created by Vokal-Ican on 06/11/26.
//

import Foundation

enum NetworkSession {
    static let api: URLSession = {
        
        let session = URLSessionConfiguration.default
        
        session.timeoutIntervalForRequest = 30
        
        session.timeoutIntervalForResource = 60
        
        session.httpAdditionalHeaders = [
            "Accept" : "application/json",
            "User-Agent" : "news-app/1.0"
        ]
        
        session.requestCachePolicy = .useProtocolCachePolicy
        
        session.allowsCellularAccess = true
        
        session.allowsConstrainedNetworkAccess = true
        
        return URLSession(configuration: session)
        
    }()
}
