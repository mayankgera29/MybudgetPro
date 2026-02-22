//
//  ProgressCell.swift
//  MyBudget Pro
//
//  Created by mayank gera on 22/01/26.
//


import UIKit

final class ProgressCell: UITableViewCell {

    private let card = CardView()
    private let titleLabel = UILabel()
    private let amountLabel = UILabel()
    private let progress = UIProgressView(progressViewStyle: .default)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {

        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        amountLabel.font = .systemFont(ofSize: 14)
        amountLabel.textColor = .label

        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true

        [card, titleLabel, amountLabel, progress].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        contentView.addSubview(card)
        card.addSubview(titleLabel)
        card.addSubview(amountLabel)
        card.addSubview(progress)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),

            amountLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            progress.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            progress.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            progress.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10)
        ])
    }

    func configure(category: CategoryType, amount: Double, max: Double) {
        titleLabel.text = "\(category.emoji) \(category.title)"
        amountLabel.text = "₹\(Int(amount))"

        progress.progress = max == 0 ? 0 : Float(amount / max)
        progress.progressTintColor = category.color
        progress.trackTintColor = category.color.withAlphaComponent(0.15)
    }
}
