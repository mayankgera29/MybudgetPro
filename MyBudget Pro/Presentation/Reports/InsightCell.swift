//
//  InsightCell.swift
//  MyBudget Pro
//

import UIKit

final class InsightCell: UITableViewCell {
    static let reuseID = "InsightCell"

    private let card = CardView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        iconView.image = UIImage(systemName: "lightbulb.fill", withConfiguration: cfg)
        iconView.tintColor = AppTheme.primary
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "Spending Insight"
        titleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textColor = AppTheme.primary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        bodyLabel.font = .systemFont(ofSize: 14, weight: .medium)
        bodyLabel.textColor = .label
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .byWordWrapping
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(card)
        card.addSubview(iconView)
        card.addSubview(titleLabel)
        card.addSubview(bodyLabel)
        card.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconView.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),

            bodyLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            bodyLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            bodyLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 10),
            bodyLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
    }

    func configure(text: String) {
        bodyLabel.text = text == "—" ? "Add more expenses to unlock spending insights." : text
    }
}
