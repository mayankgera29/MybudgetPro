//
//  CategoryDetailViewController.swift
//  MyBudget Pro
//

import UIKit
import Lottie

final class CategoryDetailViewController: UITableViewController {

    // MARK: - Dependencies
    private let viewModel: CategoryDetailViewModel

    // MARK: - Init
    init(viewModel: CategoryDetailViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavTitle()
        setupFilterButton()
        setupTable()
        viewModel.loadData()
        tableView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAppGradient()
    }

    // MARK: - Navbar
    private func setupNavTitle() {
        let label = UILabel()
        label.text = "\(viewModel.category.emoji) \(viewModel.category.title)"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .label
        navigationItem.titleView = label
    }

    private func setupFilterButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Filter",
            style: .plain,
            target: self,
            action: #selector(filterTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .label
    }

    // MARK: - Filter
    @objc private func filterTapped() {
        let sheet = UIAlertController(title: "Filter", message: nil, preferredStyle: .actionSheet)

        sheet.addAction(UIAlertAction(title: "All", style: .default) { [weak self] _ in
            self?.applyFilter(.all)
        })
        sheet.addAction(UIAlertAction(title: "Today", style: .default) { [weak self] _ in
            self?.applyFilter(.today)
        })
        sheet.addAction(UIAlertAction(title: "This Month", style: .default) { [weak self] _ in
            self?.applyFilter(.thisMonth)
        })
        sheet.addAction(UIAlertAction(title: "Custom Range", style: .default) { [weak self] _ in
            self?.openCustomPicker()
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    private func applyFilter(_ filter: DateFilter) {
        viewModel.applyFilter(filter)
        tableView.reloadData()
    }

    private func openCustomPicker() {
        let picker = CustomDatePickerViewController()
        picker.onApply = { [weak self] from, to in
            self?.applyFilter(.custom(from: from, to: to))
        }
        present(picker, animated: true)
    }

    // MARK: - Table Setup
    private func setupTable() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 83
        tableView.contentInset.bottom = tabBarHeight + 24
    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        92
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let expense = viewModel.items[indexPath.row]
        let category = viewModel.category

        let card = UIView()
        card.applyCardStyle()
        card.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(card)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8)
        ])

        let icon = LottieAnimationView(animation: LottieAnimation.named(category.lottieName))
        icon.loopMode = .loop
        icon.play()
        icon.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = expense.note.isEmpty ? category.title : expense.note
        title.font = .systemFont(ofSize: 15, weight: .medium)
        title.textColor = .label
        title.translatesAutoresizingMaskIntoConstraints = false

        let amount = UILabel()
        amount.text = CurrencyFormatter.inr(expense.amount)
        amount.font = .boldSystemFont(ofSize: 15)
        amount.textAlignment = .right
        amount.textColor = .label
        amount.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(icon)
        card.addSubview(title)
        card.addSubview(amount)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            icon.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 36),
            icon.heightAnchor.constraint(equalToConstant: 36),

            title.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            title.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            amount.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            amount.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            amount.leadingAnchor.constraint(greaterThanOrEqualTo: title.trailingAnchor, constant: 8)
        ])

        return cell
    }
}
