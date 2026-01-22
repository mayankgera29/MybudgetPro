//
//  ExpenseTileView.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//


import UIKit

final class ExpenseTileView: UIView {

    init(title: String, subtitle: String, amount: String) {
        super.init(frame: .zero)
        setupUI(title: title, subtitle: subtitle, amount: amount)
    }

    required init?(coder: NSCoder) { nil }

    private func setupUI(title: String, subtitle: String, amount: String) {

        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 16)

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .gray

        let amountLabel = UILabel()
        amountLabel.text = amount
        amountLabel.font = .boldSystemFont(ofSize: 16)

        let leftStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [leftStack, amountLabel])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.distribution = .equalSpacing
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
