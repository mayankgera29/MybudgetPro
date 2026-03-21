//
//  BudgetViewController.swift
//  MyBudget Pro
//

import UIKit

final class BudgetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let viewModel: BudgetViewModel
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var rows: [BudgetRow] = []

    // MARK: - Sections
    // Section 0: Summary card (always 1 row)
    // Section 1: Budget rows OR empty state (1 row)
    private enum Section: Int, CaseIterable { case summary, budgets }

    // MARK: - Init
    init(viewModel: BudgetViewModel = BudgetViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Budget"
        view.backgroundColor = AppTheme.background
        setupTable()
        setupAddButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
        fetchRate()
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
    private func setupTable() {
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

    private func setupAddButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(addBudgetTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = AppTheme.primary
    }

    private func reload() {
        rows = viewModel.budgetRows()
        tableView.reloadData()
    }

    private func fetchRate() {
        Task { [weak self] in
            await self?.viewModel.fetchExchangeRate()
            await MainActor.run {
                // Safe reload — only section 0 (summary)
                self?.tableView.reloadSections(IndexSet(integer: Section.summary.rawValue), with: .none)
            }
        }
    }

    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int { Section.allCases.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .summary:  return 1
        case .budgets:  return max(rows.count, 1)  // at least 1 for empty state
        case .none:     return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch Section(rawValue: indexPath.section) {
        case .summary:  return 140
        case .budgets:  return rows.isEmpty ? 220 : 90
        case .none:     return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        switch Section(rawValue: indexPath.section) {
        case .summary:
            buildSummaryCard(in: cell.contentView)
        case .budgets:
            if rows.isEmpty {
                buildEmptyState(in: cell.contentView)
            } else {
                buildBudgetRow(rows[indexPath.row], in: cell.contentView)
            }
        case .none:
            break
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard Section(rawValue: indexPath.section) == .budgets, !rows.isEmpty else { return }
        let row = rows[indexPath.row]
        showBudgetEditor(for: row.category, current: row.limit)
    }

    // MARK: - Swipe to delete budget
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        Section(rawValue: indexPath.section) == .budgets && !rows.isEmpty
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete,
              Section(rawValue: indexPath.section) == .budgets,
              indexPath.row < rows.count else { return }
        let category = rows[indexPath.row].category
        viewModel.setBudget(for: category, limit: 0)
        reload()
    }

    func tableView(_ tableView: UITableView,
                   titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        "Remove"
    }

    // MARK: - Summary Card
    private func buildSummaryCard(in container: UIView) {
        let card = UIView()
        card.backgroundColor = AppTheme.primary.withAlphaComponent(0.15)
        card.layer.cornerRadius = 20
        card.layer.borderWidth = 1
        card.layer.borderColor = AppTheme.primary.withAlphaComponent(0.3).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(card)

        let spent = viewModel.totalSpentThisMonth()
        let budget = viewModel.totalBudget()
        let usdText = viewModel.inrToUSD(spent)
        let overallRatio = budget > 0 ? min(spent / budget, 1.0) : 0

        // Left stack
        let spentTitle = makeLabel("SPENT THIS MONTH", size: 10, weight: .semibold, color: .secondaryLabel)
        let spentValue = makeLabel(CurrencyFormatter.inr(spent), size: 24, weight: .bold, color: .label)
        let usdLabel   = makeLabel(usdText == "—" ? "Fetching rate…" : "≈ \(usdText)", size: 12, weight: .medium, color: AppTheme.primary)
        let leftStack  = vstack([spentTitle, spentValue, usdLabel], spacing: 3)

        // Right stack
        let budgetTitle = makeLabel("TOTAL BUDGET", size: 10, weight: .semibold, color: .secondaryLabel)
        let budgetValue = makeLabel(budget > 0 ? CurrencyFormatter.inr(budget) : "Not set", size: 18, weight: .bold, color: .label)
        let rateLabel   = makeLabel(viewModel.rateError ?? "Live rate  ✓", size: 11, weight: .regular, color: .tertiaryLabel)
        let rightStack  = vstack([budgetTitle, budgetValue, rateLabel], spacing: 3)

        // Overall progress bar
        let track = UIView()
        track.backgroundColor = AppTheme.primary.withAlphaComponent(0.15)
        track.layer.cornerRadius = 3
        track.translatesAutoresizingMaskIntoConstraints = false

        let fill = UIView()
        fill.backgroundColor = overallRatio >= 1.0 ? .systemRed : AppTheme.primary
        fill.layer.cornerRadius = 3
        fill.translatesAutoresizingMaskIntoConstraints = false
        track.addSubview(fill)

        card.addSubview(leftStack)
        card.addSubview(rightStack)
        card.addSubview(track)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            card.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),

            leftStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            leftStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),

            rightStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            rightStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            rightStack.leadingAnchor.constraint(greaterThanOrEqualTo: leftStack.trailingAnchor, constant: 12),

            track.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            track.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            track.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
            track.heightAnchor.constraint(equalToConstant: 5),

            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: CGFloat(overallRatio))
        ])
    }

    // MARK: - Empty State
    private func buildEmptyState(in container: UIView) {
        let icon = UIImageView(image: UIImage(systemName: "target"))
        icon.tintColor = AppTheme.primary.withAlphaComponent(0.35)
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = makeLabel("No budgets set", size: 17, weight: .semibold, color: .label)
        titleLabel.textAlignment = .center

        let subLabel = makeLabel("Tap + to set a monthly limit\nfor any spending category", size: 14, weight: .regular, color: .secondaryLabel)
        subLabel.textAlignment = .center
        subLabel.numberOfLines = 2

        let stack = UIStackView(arrangedSubviews: [icon, titleLabel, subLabel])
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 64),
            icon.heightAnchor.constraint(equalToConstant: 64),
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }

    // MARK: - Budget Row
    private func buildBudgetRow(_ row: BudgetRow, in container: UIView) {
        let card = UIView()
        card.backgroundColor = AppTheme.cardBackground
        card.layer.cornerRadius = 18
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.07
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.clipsToBounds = false
        card.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(card)

        // Accent bar
        let innerClip = UIView()
        innerClip.layer.cornerRadius = 18
        innerClip.clipsToBounds = true
        innerClip.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(innerClip)

        let bar = UIView()
        bar.backgroundColor = row.isOverBudget ? .systemRed : row.category.color
        bar.translatesAutoresizingMaskIntoConstraints = false
        innerClip.addSubview(bar)

        // Icon circle
        let circle = UIView()
        circle.backgroundColor = row.category.color.withAlphaComponent(0.15)
        circle.layer.cornerRadius = 20
        circle.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(circle)

        let iconCfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let icon = UIImageView(image: UIImage(systemName: row.category.sfSymbol, withConfiguration: iconCfg))
        icon.tintColor = row.category.color
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(icon)

        // Labels
        let titleLabel  = makeLabel(row.category.title, size: 14, weight: .semibold, color: .label)
        let remainLabel = makeLabel(
            row.isOverBudget
                ? "Over by \(CurrencyFormatter.inr(row.spent - row.limit))"
                : "\(CurrencyFormatter.inr(row.remaining)) left",
            size: 11, weight: .medium,
            color: row.isOverBudget ? .systemRed : .secondaryLabel
        )
        let amountLabel = makeLabel(
            "\(CurrencyFormatter.inr(row.spent)) / \(CurrencyFormatter.inr(row.limit))",
            size: 12, weight: .semibold, color: .label
        )
        amountLabel.textAlignment = .right
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        // Progress bar
        let track = UIView()
        track.backgroundColor = row.category.color.withAlphaComponent(0.12)
        track.layer.cornerRadius = 3
        track.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(track)

        let fill = UIView()
        fill.backgroundColor = row.isOverBudget ? .systemRed : row.category.color
        fill.layer.cornerRadius = 3
        fill.translatesAutoresizingMaskIntoConstraints = false
        track.addSubview(fill)

        card.addSubview(titleLabel)
        card.addSubview(remainLabel)
        card.addSubview(amountLabel)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            card.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),

            innerClip.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            innerClip.topAnchor.constraint(equalTo: card.topAnchor),
            innerClip.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            innerClip.widthAnchor.constraint(equalToConstant: 5),

            bar.leadingAnchor.constraint(equalTo: innerClip.leadingAnchor),
            bar.topAnchor.constraint(equalTo: innerClip.topAnchor),
            bar.bottomAnchor.constraint(equalTo: innerClip.bottomAnchor),
            bar.trailingAnchor.constraint(equalTo: innerClip.trailingAnchor),

            circle.leadingAnchor.constraint(equalTo: innerClip.trailingAnchor, constant: 12),
            circle.centerYAnchor.constraint(equalTo: card.centerYAnchor, constant: -6),
            circle.widthAnchor.constraint(equalToConstant: 40),
            circle.heightAnchor.constraint(equalToConstant: 40),

            icon.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.leadingAnchor.constraint(equalTo: circle.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: circle.topAnchor, constant: 1),

            remainLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            remainLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),

            amountLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            amountLabel.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),

            track.leadingAnchor.constraint(equalTo: circle.leadingAnchor),
            track.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            track.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            track.heightAnchor.constraint(equalToConstant: 5),

            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: CGFloat(row.ratio))
        ])
    }

    // MARK: - Add / Edit
    @objc private func addBudgetTapped() {
        let picker = CategoryPickerViewController()
        picker.modalPresentationStyle = .pageSheet
        picker.onSelect = { [weak self] category in
            guard let self else { return }
            // Picker already dismissed itself; present alert directly
            self.showBudgetEditor(for: category, current: self.viewModel.currentLimit(for: category))
        }
        present(picker, animated: true)
    }

    private func showBudgetEditor(for category: CategoryType, current: Double) {
        let editor = BudgetEditorViewController(category: category, currentLimit: current)
        editor.onSave = { [weak self] amount in
            self?.viewModel.setBudget(for: category, limit: amount)
            self?.reload()
        }
        editor.onRemove = { [weak self] in
            self?.viewModel.setBudget(for: category, limit: 0)
            self?.reload()
        }
        present(editor, animated: true)
    }

    // MARK: - Helpers
    private func makeLabel(_ text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: size, weight: weight)
        l.textColor = color
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func vstack(_ views: [UIView], spacing: CGFloat) -> UIStackView {
        let s = UIStackView(arrangedSubviews: views)
        s.axis = .vertical
        s.spacing = spacing
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }
}
