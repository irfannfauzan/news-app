//
//  FetchArticleUseCase.swift
//  news-app
//
//  Created by Vokal-Ican on 06/11/26.
//

final class FetchArticleUseCase {
    private let repository: ArticleRepositoryProtocol
    
    init(repository: ArticleRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [Article] {
        try await repository.fetchArticle()
    }
}
