//
//  SummaryCell.swift
//  MyBudget Pro
//
//  Created by mayank gera on 22/01/26.
//


//
//  SummaryCell.swift
//  MyBudget Pro
//
//  Created by mayank gera on 22/01/26.
//

import UIKit

final class SummaryCell: UITableViewCell {

    private let card = CardView()
    private let totalLabel = UILabel()
    private let categoryLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        contentView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false

        totalLabel.font = .boldSystemFont(ofSize: 26)
        totalLabel.adjustsFontSizeToFitWidth = true
        totalLabel.minimumScaleFactor = 0.8
        totalLabel.numberOfLines = 2

        categoryLabel.font = .systemFont(ofSize: 14)
        categoryLabel.textColor = .label

        let stack = UIStackView(arrangedSubviews: [totalLabel, categoryLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(stack)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            stack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20)
        ])
    }


    // ✅ UPDATED API (STRING, NOT DOUBLE)
    func configure(totalText: String, topCategory: CategoryType?) {
        totalLabel.text = totalText
        categoryLabel.text = topCategory == nil
            ? "No data yet"
            : "Top category: \(topCategory!.title)"
    }
}
