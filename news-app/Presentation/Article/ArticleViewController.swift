//
//  ArticleViewController.swift
//  news-app
//
//  Created by Vokal-Ican on 06/11/26.
//

import UIKit

class ArticleViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        Task {
            let apiClient = APIClient()
            let repository = ArticleRepository(apiClient: apiClient)
            
            do {
                let articles = try await repository.fetchArticle()
                print("Berhasil: \(articles.count) artikel")

                for article in articles.prefix(3) {
                    print("- \(article.title)")
                }
            } catch {
                print("\(error.localizedDescription)")
            }
        }
    }
}
