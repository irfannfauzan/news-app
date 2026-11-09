//
//  HighlightCell.swift
//  news-app
//
//  Created by Vokal-Ican on 07/11/26.
//

import UIKit

final class HighlightCell: UICollectionViewCell {
    static let identifier = "HighlightCell"

    // MARK: - UI

    private let ringView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.layer.borderWidth = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let backgroundCircle: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func setupLayout() {
        contentView.addSubview(ringView)
        ringView.addSubview(backgroundCircle)
        backgroundCircle.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            ringView.topAnchor.constraint(equalTo: contentView.topAnchor),
            ringView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ringView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ringView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            backgroundCircle.topAnchor.constraint(equalTo: ringView.topAnchor, constant: 4),
            backgroundCircle.leadingAnchor.constraint(equalTo: ringView.leadingAnchor, constant: 4),
            backgroundCircle.trailingAnchor.constraint(equalTo: ringView.trailingAnchor, constant: -4),
            backgroundCircle.bottomAnchor.constraint(equalTo: ringView.bottomAnchor, constant: -4),

            logoImageView.topAnchor.constraint(equalTo: backgroundCircle.topAnchor, constant: 4),
            logoImageView.leadingAnchor.constraint(equalTo: backgroundCircle.leadingAnchor, constant: 4),
            logoImageView.trailingAnchor.constraint(equalTo: backgroundCircle.trailingAnchor, constant: -4),
            logoImageView.bottomAnchor.constraint(equalTo: backgroundCircle.bottomAnchor, constant: -4)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = contentView.bounds.width
        ringView.layer.cornerRadius = size / 2
        backgroundCircle.layer.cornerRadius = (size - 8) / 2
    }

    // MARK: - Configure

    func configure(imageName: String) {
        logoImageView.image = UIImage(named: imageName)
    }
}
