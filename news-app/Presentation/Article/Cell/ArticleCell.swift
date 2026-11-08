//
//  ArticleCell.swift
//  news-app
//
//  Created by Vokal-Ican on 07/11/26.
//

import UIKit

final class ArticleCell: UITableViewCell {

    static let identifier = "ArticleCell"

    private var loadTask: Task<Void, Never>?

    private var currentURL: URL?

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()

    // MARK: - UI

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = AppColors.softBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 90).isActive = true
        return imageView
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = AppColors.primary
        label.numberOfLines = 1
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = AppColors.textPrimary
        label.numberOfLines = 2
        return label
    }()

    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = AppColors.secondTextPrimary
        label.numberOfLines = 1
        return label
    }()

    private lazy var labelStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [categoryLabel, titleLabel, sourceLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        return stack
    }()

    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [posterImageView, labelStack])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        loadTask?.cancel()
        loadTask = nil
        currentURL = nil
        showPlaceholder()
        categoryLabel.text = nil
        titleLabel.text = nil
        sourceLabel.text = nil
    }

    // MARK: - Image

    private func showPlaceholder() {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        posterImageView.contentMode = .center
        posterImageView.tintColor = AppColors.secondTextPrimary
        posterImageView.image = UIImage(systemName: "photo", withConfiguration: config)
    }

    private func showImage(_ image: UIImage?) {
        guard let image else { return }
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.image = image
    }

    // MARK: - Configure

    func configure(with article: Article, category: String) {
        categoryLabel.text = category
        titleLabel.text = article.title
        currentURL = article.urlImage

        if let date = article.publishedAt {
            sourceLabel.text = "\(article.source.name) • \(Self.dateFormatter.string(from: date))"
        } else {
            sourceLabel.text = article.source.name
        }

        loadTask?.cancel()
        showPlaceholder()

        guard let url = article.urlImage else { return }

        if let cached = ImageLoader.shared.cacheImage(for: url) {
            showImage(cached)
            return
        }

        loadTask = Task { [weak self] in
            let image = await ImageLoader.shared.load(url)
            guard !Task.isCancelled, self?.currentURL == url else { return }
            self?.showImage(image)
        }
    }
}
