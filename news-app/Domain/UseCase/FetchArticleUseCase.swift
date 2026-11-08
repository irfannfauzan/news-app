//
//  FetchNewsListUseCase.swift
//  news-app
//
//  Created by Vokal-Ican on 06/11/26.
//

final class FetchNewsListUseCase {
    private let repository: NewsListRepositoryProtocol
    
    init(repository: NewsListRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [NewsList] {
        try await repository.fetchNewsList()
    }
}
