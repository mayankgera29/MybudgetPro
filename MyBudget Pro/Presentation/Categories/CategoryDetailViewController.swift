//
//  CategoryDetailViewController.swift
//  MyBudget Pro
//

import UIKit

final class CategoryDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Dependencies
    private let viewModel: CategoryDetailViewModel

    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - Init
    init(viewModel: CategoryDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        setupNavTitle()
        setupFilterButton()
        setupTableView()
        viewModel.loadData()
        tableView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAppGradient()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        view.refreshAppGradient()
        tableView.reloadData()
    }

    // MARK: - Setup
    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
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
        sheet.addAction(UIAlertAction(title: "All",        style: .default) { [weak self] _ in self?.applyFilter(.all) })
        sheet.addAction(UIAlertAction(title: "Today",      style: .default) { [weak self] _ in self?.applyFilter(.today) })
        sheet.addAction(UIAlertAction(title: "This Month", style: .default) { [weak self] _ in self?.applyFilter(.thisMonth) })
        sheet.addAction(UIAlertAction(title: "Custom Range", style: .default) { [weak self] _ in self?.openCustomPicker() })
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

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 92 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let expense  = viewModel.items[indexPath.row]
        let category = viewModel.category

        let card = UIView()
        card.applyCardStyle()
        card.clipsToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(card)

        let bar = UIView()
        bar.backgroundColor = category.color
        bar.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(bar)

        let icon = UILabel()
        icon.text = category.emoji
        icon.font = .systemFont(ofSize: 28)
        icon.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = expense.note.isEmpty ? category.title : expense.note
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let amountLabel = UILabel()
        amountLabel.text = CurrencyFormatter.inr(expense.amount)
        amountLabel.font = .boldSystemFont(ofSize: 15)
        amountLabel.textAlignment = .right
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        amountLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(icon)
        card.addSubview(titleLabel)
        card.addSubview(amountLabel)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),

            bar.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            bar.topAnchor.constraint(equalTo: card.topAnchor),
            bar.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            bar.widthAnchor.constraint(equalToConstant: 5),

            icon.leadingAnchor.constraint(equalTo: bar.trailingAnchor, constant: 12),
            icon.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 36),
            icon.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),

            amountLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            amountLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])

        return cell
    }

    // MARK: - Delete
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let expense = viewModel.items[indexPath.row]
        viewModel.deleteExpense(id: expense.id)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
