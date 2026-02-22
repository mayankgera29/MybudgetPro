//
//  InsightCell.swift
//  MyBudget Pro
//
//  Created by mayank gera on 22/01/26.
//

//
//  InsightCell.swift
//  MyBudget Pro
//
//  Created by mayank gera on 22/01/26.
//

import UIKit

final class InsightCell: UITableViewCell {

    private let card = CardView()
    private let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textColor = .label

        contentView.addSubview(card)
        card.addSubview(label)

        card.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
    }

    func configure(text: String) {
        label.text = text
    }
}
