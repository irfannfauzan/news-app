//
//  ArticleViewModel.swift
//  news-app
//
//  Created by Vokal-Ican on 06/11/26.
//

import Foundation

@MainActor
final class ArticleViewModel {
    
    private(set) var state: ArticleState = .loading {
        didSet { onStatusChange?(state) }
    }
    
    var onStatusChange: ((ArticleState) -> Void)?
    
    private let fetchArticle: FetchArticleUseCase
    
    private(set) var article: [Article] = []
    
    init(fetchArticle: FetchArticleUseCase) {
        self.fetchArticle = fetchArticle
    }
    
    func loadArticles() async {
        state = .loading
        do {
            let result = try await fetchArticle.execute()
            article = result
            state = result.isEmpty ? .isEmpty : .loaded(result)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
