//
//  ArticleRepositoryProtocol.swift
//  news-app
//
//  Created by Vokal-Ican on 06/11/26.
//

protocol ArticleRepositoryProtocol {
    func fetchArticle() async throws -> [Article]
}
