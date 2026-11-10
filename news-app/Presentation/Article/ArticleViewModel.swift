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
    
    private(set) var lastUpdated: Date?
    
    private(set) var isOffline = false
    
    private let refreshInterval: TimeInterval = 10 * 60
    
    private static let relativeFormatted: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.unitsStyle = .full
        return formatter
    }()
    
    init(fetchArticle: FetchArticleUseCase) {
        self.fetchArticle = fetchArticle
    }
    
    func loadArticles() async {
        state = .loading
        do {
            let feed = try await fetchArticle.execute()
            article = feed.articles
            lastUpdated = feed.updatedAt
            isOffline = feed.isOffline
            state = feed.articles.isEmpty ? .isEmpty : .loaded(feed.articles)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func refreshIfNeeded() async {
        guard let lastUpdated, !isOffline else {
            await loadArticles()
            return
        }
        if Date().timeIntervalSince(lastUpdated) > refreshInterval {
            await loadArticles()
        }
    }
    
    var lastUpdatedText: String? {
        guard let lastUpdated else { return nil }
        let relative = Self.relativeFormatted.localizedString(for: lastUpdated, relativeTo: Date())
        let text = "Diperbarui \(relative) lalu"
        return isOffline ? "Mode Offline \(text)" : text
    }
}
