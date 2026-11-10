//
//  ArticleRepository.swift
//  news-app
//
//  Created by Vokal-Ican on 06/11/26.
//

import Foundation

final class ArticleRepository: ArticleRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let cache: ArticleCacheProtocol
    
    init(apiClient: APIClientProtocol, cache: ArticleCacheProtocol) {
        self.apiClient = apiClient
        self.cache = cache
    }
    
    func fetchArticle() async throws -> ArticleFeed {
        do {
            let response: ArticleResponseDTO = try await apiClient.request(.fetchArticle)
            let articles = response.articles.compactMap( {$0.toDomain()} )
            let now = Date()
            
            try? cache.save(articles, savedAt: now)
            
            return ArticleFeed(articles: articles, updatedAt: now, isOffline: false)
            
        } catch APIError.transportError(let urlError) {
            if let cached = cache.load() {
                return ArticleFeed(articles: cached.article, updatedAt: cached.savedAt, isOffline: true)
            }
            throw APIError.transportError(urlError)
        }
    }
}


