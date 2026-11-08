//
//  NewsList.swift
//  news-app
//
//  Created by Vokal-Ican on 06/11/26.
//

import Foundation

// MARK: - Entities

struct ArticleSource {
    let id: String?
    let name: String
}

struct Article {
    let source: ArticleSource
    let author: String
    let title: String
    let description: String
    let url: URL
    let urlImage: URL?
    let publishedAt: Date?
    let content: String
}
