//
//  ArticleDetailViewController.swift
//  news-app
//
//  Created by Vokal-Ican on 08/11/26.
//

import UIKit

final class ArticleDetailViewController: UIViewController {

    private let article: Article
    private let category: String

    private let headerHeight: CGFloat = 400
    private let cardOverlap: CGFloat = 24

    private var imageTask: Task<Void, Never>?

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()

    // MARK: - Init

    init(article: Article, category: String) {
        self.article = article
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = AppColors.softBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
        layer.locations = [0.1, 1.0]
        return layer
    }()

    private let categoryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = AppColors.primary
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)
        let button = UIButton(configuration: config)
        button.isUserInteractionEnabled = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private let metaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        return label
    }()

    private lazy var headerTextStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [categoryButton, titleLabel, metaLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.background
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let sourceInitialLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = AppColors.primary
        label.textAlignment = .center
        label.backgroundColor = .systemGray6
        label.layer.cornerRadius = 18
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 36).isActive = true
        label.heightAnchor.constraint(equalToConstant: 36).isActive = true
        return label
    }()

    private let sourceNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = AppColors.textPrimary
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let followButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.title = "Follow"
        config.image = UIImage(systemName: "plus")
        config.imagePadding = 4
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        config.baseForegroundColor = AppColors.primary
        config.cornerStyle = .capsule
        return UIButton(configuration: config)
    }()

    private lazy var sourceStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [sourceInitialLabel, sourceNameLabel, followButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var backButton = makeCircleButton(systemName: "chevron.left")
    private lazy var moreButton = makeCircleButton(systemName: "ellipsis")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupLayout()
        setupActions()
        configureContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        if headerImageView.image == nil {
            loadHeaderImage()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        imageTask?.cancel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = headerImageView.bounds
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: - Setup

    private func makeCircleButton(systemName: String) -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        button.setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 18
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 36).isActive = true
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        return button
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(headerImageView)
        headerImageView.layer.addSublayer(gradientLayer)
        contentView.addSubview(headerTextStack)
        contentView.addSubview(cardView)

        cardView.addSubview(sourceStack)
        cardView.addSubview(bodyLabel)

        view.addSubview(backButton)
        view.addSubview(moreButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            headerImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerImageView.heightAnchor.constraint(equalToConstant: headerHeight),

            headerTextStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerTextStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            headerTextStack.bottomAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: -(cardOverlap + 16)),

            cardView.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: -cardOverlap),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            sourceStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            sourceStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            sourceStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            bodyLabel.topAnchor.constraint(equalTo: sourceStack.bottomAnchor, constant: 16),
            bodyLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            bodyLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            bodyLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -32),

            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            moreButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            moreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
    }

    // MARK: - Content

    private func configureContent() {
        categoryButton.configuration?.attributedTitle = AttributedString(
            category,
            attributes: AttributeContainer([.font: UIFont.systemFont(ofSize: 11, weight: .medium)])
        )

        titleLabel.text = article.title

        var metaParts: [String] = []
        if let date = article.publishedAt {
            metaParts.append(Self.dateFormatter.string(from: date))
        }
        metaParts.append("\(readingTime()) menit baca")
        metaLabel.text = metaParts.joined(separator: " • ")

        sourceNameLabel.text = article.source.name
        sourceInitialLabel.text = String(article.source.name.prefix(1)).uppercased()

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4

        bodyLabel.attributedText = NSAttributedString(
            string: bodyText(),
            attributes: [
                .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                .foregroundColor: AppColors.textPrimary,
                .paragraphStyle: paragraph
            ]
        )
    }

    private func bodyText() -> String {
        let content = article.content.replacingOccurrences(
            of: "\\s*\\[\\+\\d+ chars\\]",
            with: "",
            options: .regularExpression
        )

        return [article.description, content]
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
    }

    private func readingTime() -> Int {
        let words = bodyText().split(whereSeparator: { $0.isWhitespace }).count
        return max(1, words / 200)
    }

    private func loadHeaderImage() {
        guard let url = article.urlImage else { return }

        if let cached = ImageLoader.shared.cacheImage(for: url) {
            headerImageView.image = cached
            return
        }

        imageTask?.cancel()
        imageTask = Task { [weak self] in                          
            let image = await ImageLoader.shared.load(url)
            guard !Task.isCancelled else { return }
            self?.headerImageView.image = image
        }
    }

    // MARK: - Actions

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapMore() {
        let items: [Any] = [article.title, article.url]
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)

        if let popover = activity.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        present(activity, animated: true)
    }
}

// MARK: - Swipe Back

extension ArticleDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        (navigationController?.viewControllers.count ?? 0) > 1
    }
}
