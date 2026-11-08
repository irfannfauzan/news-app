//
//  NewsListRepositoryProtocol.swift
//  news-app
//
//  Created by Vokal-Ican on 06/11/26.
//

protocol NewsListRepositoryProtocol {
    func fetchNewsList() async throws -> [NewsList]
}
