//
//  Endpoint.swift
//  news-app
//
//  Created by Vokal-Ican on 06/11/26.
//

import Foundation

enum Endpoint {
    case fetchArticle
    
    private static let baseURL = "https://newsapi.org/v2"
    private static let region = "us"
    private static let category = "technology"
    
    private var path: String {
        switch self {
            case .fetchArticle:
            return "/top-headlines"
        }
    }
    
    private var queryItems: [URLQueryItem] {
        var items = [URLQueryItem(name: "country", value: Self.region)]
        
        switch self {
            case .fetchArticle:
            items.append(URLQueryItem(name: "category", value: Self.category))
            items.append(URLQueryItem(name: "pageSize", value: "100"))
        }
        
        return items
    }
    
    func url() -> URL? {
        var components = URLComponents(string: Self.baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
}
