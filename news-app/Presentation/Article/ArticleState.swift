//
//  ArticleState.swift
//  news-app
//
//  Created by Vokal-Ican on 06/11/26.
//

enum ArticleState {
    case loading
    case loaded([Article])
    case isEmpty
    case error(String)
}
