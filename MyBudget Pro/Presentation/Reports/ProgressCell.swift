//
//  ProgressCell.swift
//  MyBudget Pro
//

import UIKit

final class ProgressCell: UITableViewCell {
    static let reuseID = "ProgressCell"

    private let card = CardView()
    private let colorBar = UIView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let amountLabel = UILabel()
    private let percentLabel = UILabel()
    private let trackView = UIView()
    private let fillView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        // Accent bar (clipped)
        let innerClip = UIView()
        innerClip.layer.cornerRadius = 16
        innerClip.clipsToBounds = true
        innerClip.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(innerClip)
        colorBar.translatesAutoresizingMaskIntoConstraints = false
        innerClip.addSubview(colorBar)

        emojiLabel.font = .systemFont(ofSize: 22)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        amountLabel.font = .systemFont(ofSize: 13, weight: .bold)
        amountLabel.textColor = .label
        amountLabel.textAlignment = .right
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        amountLabel.translatesAutoresizingMaskIntoConstraints = false

        percentLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        percentLabel.textColor = .secondaryLabel
        percentLabel.textAlignment = .right
        percentLabel.translatesAutoresizingMaskIntoConstraints = false

        trackView.layer.cornerRadius = 3
        trackView.translatesAutoresizingMaskIntoConstraints = false
        fillView.layer.cornerRadius = 3
        fillView.translatesAutoresizingMaskIntoConstraints = false
        trackView.addSubview(fillView)

        contentView.addSubview(card)
        card.addSubview(emojiLabel)
        card.addSubview(titleLabel)
        card.addSubview(amountLabel)
        card.addSubview(percentLabel)
        card.addSubview(trackView)
        card.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),

            innerClip.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            innerClip.topAnchor.constraint(equalTo: card.topAnchor),
            innerClip.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            innerClip.widthAnchor.constraint(equalToConstant: 5),

            colorBar.leadingAnchor.constraint(equalTo: innerClip.leadingAnchor),
            colorBar.topAnchor.constraint(equalTo: innerClip.topAnchor),
            colorBar.bottomAnchor.constraint(equalTo: innerClip.bottomAnchor),
            colorBar.trailingAnchor.constraint(equalTo: innerClip.trailingAnchor),

            emojiLabel.leadingAnchor.constraint(equalTo: innerClip.trailingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),

            titleLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: emojiLabel.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),

            amountLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            amountLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),

            percentLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            percentLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 2),

            trackView.leadingAnchor.constraint(equalTo: emojiLabel.leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            trackView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 10),
            trackView.heightAnchor.constraint(equalToConstant: 5),
            trackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),

            fillView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            fillView.topAnchor.constraint(equalTo: trackView.topAnchor),
            fillView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor)
        ])
    }

    // fillView width set via tag-based constraint
    private var fillWidthConstraint: NSLayoutConstraint?

    func configure(category: CategoryType, amount: Double, max: Double) {
        emojiLabel.text = category.emoji
        titleLabel.text = category.title
        amountLabel.text = CurrencyFormatter.inr(amount)
        colorBar.backgroundColor = category.color
        trackView.backgroundColor = category.color.withAlphaComponent(0.12)
        fillView.backgroundColor = category.color

        let ratio = max > 0 ? CGFloat(amount / max) : 0
        let pct = max > 0 ? Int((amount / max) * 100) : 0
        percentLabel.text = "\(pct)% of top"

        fillWidthConstraint?.isActive = false
        fillWidthConstraint = fillView.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: ratio)
        fillWidthConstraint?.isActive = true
    }
}
