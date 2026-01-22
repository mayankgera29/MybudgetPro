//
//  CategoriesViewController.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//


import UIKit

final class CategoriesViewController: UIViewController {

    private let viewModel = CategoriesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Categories"

        // ✅ Filter button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Filter",
            style: .plain,
            target: self,
            action: #selector(filterTapped)
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(render),
            name: .expenseUpdated,
            object: nil
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAppGradient()
        render()
    }

    // MARK: - Filter Action
    @objc private func filterTapped() {

        let sheet = UIAlertController(
            title: "Filter by Date",
            message: nil,
            preferredStyle: .actionSheet
        )

        sheet.addAction(UIAlertAction(title: "All", style: .default) { _ in
            self.viewModel.setFilter(.all)
            self.render()
        })

        sheet.addAction(UIAlertAction(title: "Today", style: .default) { _ in
            self.viewModel.setFilter(.today)
            self.render()
        })

        sheet.addAction(UIAlertAction(title: "This Month", style: .default) { _ in
            self.viewModel.setFilter(.thisMonth)
            self.render()
        })

        // ✅ CUSTOM DATE (CORRECT WAY)
        sheet.addAction(UIAlertAction(title: "Custom Date", style: .default) { _ in
            self.openCustomDatePicker()
        })

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    // MARK: - Custom Date Picker
    private func openCustomDatePicker() {

        let pickerVC = CustomDatePickerViewController()
        pickerVC.modalPresentationStyle = .pageSheet

        pickerVC.onApply = { [weak self] from, to in
            self?.viewModel.setFilter(.custom(from: from, to: to))
            self?.render()
        }

        present(pickerVC, animated: true)
    }

    // MARK: - Render (UNCHANGED TILE UI)
    @objc private func render() {

        view.subviews.forEach { $0.removeFromSuperview() }

        var y: CGFloat = 120
        let data = viewModel.getCategoryTotals()   // ✅ filtered internally

        for (category, total) in data {

            let tile = UIView(frame: CGRect(
                x: 20,
                y: y,
                width: view.bounds.width - 40,
                height: 70
            ))
            tile.applyCardStyle()

            let label = UILabel(frame: CGRect(
                x: 16,
                y: 22,
                width: tile.bounds.width - 32,
                height: 24
            ))
            label.text = "\(category.emoji) \(category.title) ₹\(Int(total))"
            label.font = .boldSystemFont(ofSize: 16)

            tile.addSubview(label)
            view.addSubview(tile)

            y += 90
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

