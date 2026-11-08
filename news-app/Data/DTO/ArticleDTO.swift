//
//  ArticleDTO.swift
//  news-app
//
//  Created by Vokal-Ican on 06/11/26.
//

import Foundation

// MARK: - DTO

struct ArticleResponseDTO: Decodable {
    let status: String
    let totalResults: Int
    let articles: [ArticleDTO]
}

struct ArticleDTO: Decodable {
    let source: ArticleSourceDTO
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlImage: String?
    let publishedAt: String?
    let content: String?

    enum CodingKeys: String, CodingKey {
        case source, author, title, description, url, publishedAt, content
        case urlImage = "urlToImage"
    }
}

struct ArticleSourceDTO: Decodable {
    let id: String?
    let name: String?
}

struct NewsAPIErrorDTO: Decodable {
    let status: String?
    let code: String?
    let message: String?
}

// MARK: - Mapping

extension ArticleSourceDTO {
    func toDomain() -> ArticleSource {
        ArticleSource(id: id, name: name ?? "Unknown")
    }
}

extension ArticleDTO {
    private static let isoFormatter = ISO8601DateFormatter()

    func toDomain() -> Article? {
        guard let title, let url = url.flatMap(URL.init(string:)) else {
            return nil
        }

        return Article(
            source: source.toDomain(),
            author: author ?? "Unknown",
            title: title,
            description: description ?? "",
            url: url,
            urlImage: urlImage.flatMap(URL.init(string:)),
            publishedAt: publishedAt.flatMap { Self.isoFormatter.date(from: $0) },  
            content: content ?? ""
        )
    }
}
