//
//  CategoryPickerViewController.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//


import UIKit

final class CategoryPickerViewController: UIViewController {

    var onSelect: ((CategoryType) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(
            red: 245/255,
            green: 247/255,
            blue: 250/255,
            alpha: 1
        )
        setupSheet()
        setupTiles()
    }

    private func setupSheet() {
        if let sheet = sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
    }

    private func setupTiles() {

        var y: CGFloat = 20

        for category in CategoryType.allCases {

            let tile = UIButton(frame: CGRect(
                x: 20,
                y: y,
                width: view.bounds.width - 40,
                height: 60
            ))

            tile.backgroundColor = category.backgroundColor
            tile.layer.cornerRadius = 16
            tile.setTitle("  \(category.emoji)  \(category.title)", for: .normal)
            tile.setTitleColor(.black, for: .normal)
            tile.contentHorizontalAlignment = .left
            tile.titleLabel?.font = .boldSystemFont(ofSize: 18)

            tile.addAction(
                UIAction { [weak self] _ in
                    self?.onSelect?(category)
                    self?.dismiss(animated: true)
                },
                for: .touchUpInside
            )

            view.addSubview(tile)
            y += 76
        }
    }
}

