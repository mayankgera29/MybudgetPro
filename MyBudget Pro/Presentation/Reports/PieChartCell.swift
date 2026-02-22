//
//  PieChartCell.swift
//  MyBudget Pro
//
//  Created by mayank gera on 22/01/26.
//


import UIKit

final class PieChartCell: UITableViewCell {

    private let card = CardView()
    private let titleLabel = UILabel()
    private let pieChart = PieChartView()
    private let totalLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {

        titleLabel.text = "Spending Distribution"
        titleLabel.font = .boldSystemFont(ofSize: 18)

        totalLabel.font = .systemFont(ofSize: 14)
        totalLabel.textColor = .secondaryLabel
        totalLabel.textAlignment = .center

        [card, titleLabel, pieChart, totalLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        contentView.addSubview(card)
        card.addSubview(titleLabel)
        card.addSubview(pieChart)
        card.addSubview(totalLabel)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),

            pieChart.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            pieChart.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            pieChart.widthAnchor.constraint(equalToConstant: 220),
            pieChart.heightAnchor.constraint(equalToConstant: 220),

            totalLabel.topAnchor.constraint(equalTo: pieChart.bottomAnchor, constant: 8),
            totalLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor)
        ])
    }

    func configure(slices: [PieChartView.Slice], total: Double) {
        totalLabel.text = "Total: ₹\(Int(total))"
        pieChart.configure(with: slices)
    }
}
