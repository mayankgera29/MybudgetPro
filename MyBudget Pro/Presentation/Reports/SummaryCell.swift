//
//  SummaryCell.swift
//  MyBudget Pro
//

import UIKit

final class SummaryCell: UITableViewCell {
    static let reuseID = "SummaryCell"

    private let card = CardView()
    private let tagLabel = UILabel()
    private let totalLabel = UILabel()
    private let topCategoryLabel = UILabel()
    private let topCategoryBadge = UIView()
    private let topCategoryBadgeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        tagLabel.text = "TOTAL SPENDING"
        tagLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        tagLabel.textColor = .secondaryLabel
        tagLabel.translatesAutoresizingMaskIntoConstraints = false

        totalLabel.font = .systemFont(ofSize: 30, weight: .bold)
        totalLabel.adjustsFontSizeToFitWidth = true
        totalLabel.minimumScaleFactor = 0.7
        totalLabel.numberOfLines = 1
        totalLabel.translatesAutoresizingMaskIntoConstraints = false

        topCategoryLabel.font = .systemFont(ofSize: 12, weight: .medium)
        topCategoryLabel.textColor = .secondaryLabel
        topCategoryLabel.translatesAutoresizingMaskIntoConstraints = false

        // Top category badge
        topCategoryBadge.backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
        topCategoryBadge.layer.cornerRadius = 10
        topCategoryBadge.translatesAutoresizingMaskIntoConstraints = false

        topCategoryBadgeLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        topCategoryBadgeLabel.textColor = AppTheme.primary
        topCategoryBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        topCategoryBadge.addSubview(topCategoryBadgeLabel)

        contentView.addSubview(card)
        card.addSubview(tagLabel)
        card.addSubview(totalLabel)
        card.addSubview(topCategoryLabel)
        card.addSubview(topCategoryBadge)
        card.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            tagLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            tagLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),

            totalLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            totalLabel.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: 4),
            totalLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            topCategoryLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            topCategoryLabel.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 6),
            topCategoryLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),

            topCategoryBadge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            topCategoryBadge.centerYAnchor.constraint(equalTo: topCategoryLabel.centerYAnchor),

            topCategoryBadgeLabel.topAnchor.constraint(equalTo: topCategoryBadge.topAnchor, constant: 4),
            topCategoryBadgeLabel.bottomAnchor.constraint(equalTo: topCategoryBadge.bottomAnchor, constant: -4),
            topCategoryBadgeLabel.leadingAnchor.constraint(equalTo: topCategoryBadge.leadingAnchor, constant: 10),
            topCategoryBadgeLabel.trailingAnchor.constraint(equalTo: topCategoryBadge.trailingAnchor, constant: -10)
        ])
    }

    func configure(totalText: String, topCategory: CategoryType?) {
        totalLabel.text = totalText
        if let cat = topCategory {
            topCategoryLabel.text = "Top: \(cat.emoji) \(cat.title)"
            topCategoryBadgeLabel.text = "Highest spend"
            topCategoryBadge.isHidden = false
        } else {
            topCategoryLabel.text = "No expenses yet"
            topCategoryBadge.isHidden = true
        }
    }
}
