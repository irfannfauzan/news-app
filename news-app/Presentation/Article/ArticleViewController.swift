//
//  ArticleViewController.swift
//  news-app
//
//  Created by Vokal-Ican on 06/11/26.
//

import UIKit

struct SourceItem {
    let name: String
    let imageName: String
}

class ArticleViewController: UIViewController {

    private let viewModel: ArticleViewModel

    private let sources: [SourceItem] = [
        SourceItem(name: "BBC News", imageName: "bbc"),
        SourceItem(name: "bloomberg", imageName: "bloomberg"),
        SourceItem(name: "NBC News", imageName: "nbc"),
        SourceItem(name: "beIN Sports", imageName: "bein"),
        SourceItem(name: "ESPN", imageName: "espn"),
        SourceItem(name: "Aljazeera", imageName: "aljazeera")
    ]

    // MARK: - Init

    init(viewModel: ArticleViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = AppColors.primary
        control.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return control
    }()

    private lazy var sourceCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HighlightCell.self, forCellWithReuseIdentifier: HighlightCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var articleTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ArticleCell.self, forCellReuseIdentifier: ArticleCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = AppColors.secondTextPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let notificationButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        button.setImage(UIImage(systemName: "bell.fill", withConfiguration: config), for: .normal)
        button.tintColor = AppColors.primary
        button.layer.cornerRadius = 20
        button.backgroundColor = .systemGray6
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - UI Appbar

    private let appbarLabel: UILabel = {
        let label = UILabel()
        label.text = "Top Stories"
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.text = "Latest News"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupAppbar()
        setupLayout()
        bindViewModel()

        Task {
            await viewModel.loadArticles()
        }
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(sourceCollectionView)
        view.addSubview(headlineLabel)
        view.addSubview(articleTableView)
        view.addSubview(loadingIndicator)
        view.addSubview(messageLabel)
        articleTableView.refreshControl = refreshControl

        NSLayoutConstraint.activate([
            sourceCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            sourceCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sourceCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sourceCollectionView.heightAnchor.constraint(equalToConstant: 60),

            headlineLabel.topAnchor.constraint(equalTo: sourceCollectionView.bottomAnchor, constant: 24),
            headlineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headlineLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            articleTableView.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 8),
            articleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            articleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            articleTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: articleTableView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: articleTableView.centerYAnchor),

            messageLabel.centerYAnchor.constraint(equalTo: articleTableView.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func setupAppbar() {
        let leftAppbar = UIBarButtonItem(customView: appbarLabel)
        let rightAppbar = UIBarButtonItem(customView: notificationButton)

        if #available(iOS 26.0, *) {
            leftAppbar.hidesSharedBackground = true
            rightAppbar.hidesSharedBackground = true
        }

        navigationItem.leftBarButtonItem = leftAppbar
        navigationItem.rightBarButtonItem = rightAppbar
    }

    // MARK: - Binding

    private func bindViewModel() {
        viewModel.onStatusChange = { [weak self] state in
            self?.render(state)
        }

        render(viewModel.state)
    }

    private func render(_ state: ArticleState) {
        switch state {
        case .loading:
            if !refreshControl.isRefreshing {
                loadingIndicator.startAnimating()
            }
            messageLabel.isHidden = true

        case .loaded:
            loadingIndicator.stopAnimating()
            refreshControl.endRefreshing()
            messageLabel.isHidden = true
            articleTableView.reloadData()

        case .isEmpty:
            loadingIndicator.stopAnimating()
            refreshControl.endRefreshing()
            messageLabel.text = "No news available."
            messageLabel.isHidden = false
            articleTableView.reloadData()

        case .error(let message):
            loadingIndicator.stopAnimating()
            refreshControl.endRefreshing()

            if viewModel.article.isEmpty {
                messageLabel.text = message
                messageLabel.isHidden = false
            } else {
                showErrorAlert(message)
            }
        }
    }

    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Failed to load", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Actions

    @objc private func didPullToRefresh() {
        Task {
            await viewModel.loadArticles()
        }
    }
}

// MARK: - CollectionView

extension ArticleViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sources.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HighlightCell.identifier,
            for: indexPath
        ) as? HighlightCell else {
            return UICollectionViewCell()
        }

        cell.configure(imageName: sources[indexPath.item].imageName)
        return cell
    }
}

extension ArticleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Pilih: \(sources[indexPath.item].name)")
    }
}

// MARK: - TableView

extension ArticleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.article.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ArticleCell.identifier,
            for: indexPath
        ) as? ArticleCell else {
            return UITableViewCell()
        }

        cell.configure(with: viewModel.article[indexPath.row], category: "Technology")
        return cell
    }
}

extension ArticleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = ArticleDetailViewController(
            article: viewModel.article[indexPath.row],
            category: "Technology"
        )
        navigationController?.pushViewController(detail, animated: true)
    }
}
