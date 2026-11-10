//
//  ArticleCache.swift
//  news-app
//
//  Created by Vokal-Ican on 10/11/26.
//

import Foundation

protocol ArticleCacheProtocol {
    func save(_ articles: [Article], savedAt: Date) throws
    func load() -> (article: [Article], savedAt: Date)?
}

final class ArticleFileCache: ArticleCacheProtocol {
    
    private struct CacheFile: Codable {
        let savedAt: Date
        let articles: [Article]
    }
    
    private let fileURL: URL
    
    init(fileName: String = "articles.json") {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        fileURL = caches.appendingPathComponent(fileName)
    }
    
    func save(_ articles: [Article], savedAt: Date) throws {
        let file = CacheFile(savedAt: savedAt, articles: articles)
        let data = try JSONEncoder().encode(file)
        try data.write(to: fileURL, options: .atomic)
    }
    
    func load() -> (article: [Article], savedAt: Date)? {
        guard let data = try? Data(contentsOf: fileURL),
              let file = try? JSONDecoder().decode(CacheFile.self, from: data) else {
            return nil
        }
        return (file.articles, file.savedAt)
    }
}
