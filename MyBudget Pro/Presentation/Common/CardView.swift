//
//  CardView.swift
//  MyBudget Pro
//
//  Created by mayank gera on 22/01/26.
//


import UIKit

final class CardView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = AppTheme.cardBackground
        layer.cornerRadius = 16

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }
}
