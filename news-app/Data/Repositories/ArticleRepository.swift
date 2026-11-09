//
//  ArticleRepository.swift
//  news-app
//
//  Created by Vokal-Ican on 06/11/26.
//

import Foundation

final class ArticleRepository: ArticleRepositoryProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func fetchArticle() async throws -> [Article] {
        let response: ArticleResponseDTO = try await apiClient.request(.fetchArticle)
        let article = response.articles.compactMap( {$0.toDomain()} )
        return article
    }
}


