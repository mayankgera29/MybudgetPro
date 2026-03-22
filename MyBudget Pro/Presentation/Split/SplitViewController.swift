//
//  SplitViewController.swift
//  MyBudget Pro
//

import UIKit

final class SplitViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Dependencies
    private let viewModel: SplitViewModel

    init(viewModel: SplitViewModel = SplitViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let addButton = UIButton(type: .system)

    // MARK: - Sections
    private enum Section: Int, CaseIterable {
        case summary, balances, expenses
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        view.addBackgroundLottie(named: "background_motion")
        setupTable()
        setupAddButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reload()
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
    private func setupTable() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 100, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupAddButton() {
        // FAB is managed by the parent HomeViewController when embedded
        // Only show if presented standalone
        guard parent == nil || parent is UINavigationController else { return }
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .white
        addButton.backgroundColor = AppTheme.primary
        addButton.layer.cornerRadius = 28
        addButton.layer.shadowColor = AppTheme.primary.cgColor
        addButton.layer.shadowOpacity = 0.45
        addButton.layer.shadowRadius = 12
        addButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: 56),
            addButton.heightAnchor.constraint(equalToConstant: 56),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])
    }

    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int { Section.allCases.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .summary:  return 1
        case .balances: return max(viewModel.balanceSummaries().count, viewModel.people.isEmpty ? 0 : 1)
        case .expenses: return max(viewModel.recentExpenses.count, 1)
        case .none:     return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch Section(rawValue: indexPath.section) {
        case .summary:  return 130
        case .balances: return viewModel.balanceSummaries().isEmpty ? 0 : 72
        case .expenses: return viewModel.recentExpenses.isEmpty ? 180 : 84
        case .none:     return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch Section(rawValue: section) {
        case .balances where !viewModel.people.isEmpty:
            return makeSectionHeader("Balances")
        case .expenses:
            return makeSectionHeader("Split Expenses")
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch Section(rawValue: section) {
        case .balances where !viewModel.people.isEmpty: return 36
        case .expenses: return 36
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        switch Section(rawValue: indexPath.section) {
        case .summary:
            buildSummaryCard(in: cell.contentView)
        case .balances:
            let summaries = viewModel.balanceSummaries()
            if indexPath.row < summaries.count {
                buildBalanceRow(summaries[indexPath.row], in: cell.contentView)
            }
        case .expenses:
            let expenses = viewModel.recentExpenses
            if expenses.isEmpty {
                buildEmptyState(in: cell.contentView)
            } else if indexPath.row < expenses.count {
                buildExpenseRow(expenses[indexPath.row], in: cell.contentView)
            }
        case .none: break
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard Section(rawValue: indexPath.section) == .expenses else { return }
        let expenses = viewModel.recentExpenses
        guard indexPath.row < expenses.count else { return }
        showExpenseDetail(expenses[indexPath.row])
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        Section(rawValue: indexPath.section) == .expenses && !viewModel.recentExpenses.isEmpty
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete, Section(rawValue: indexPath.section) == .expenses else { return }
        let expenses = viewModel.recentExpenses
        guard indexPath.row < expenses.count else { return }
        viewModel.deleteExpense(id: expenses[indexPath.row].id)
        tableView.reloadData()
    }

    // MARK: - Summary Card
    private func buildSummaryCard(in container: UIView) {
        let card = UIView()
        card.backgroundColor = AppTheme.primary.withAlphaComponent(0.12)
        card.layer.cornerRadius = 22
        card.layer.borderWidth = 1
        card.layer.borderColor = AppTheme.primary.withAlphaComponent(0.25).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(card)

        let owedToYou = viewModel.totalOwedToYou
        let youOwe    = viewModel.totalYouOwe

        // Left: owed to you
        let leftTag   = label("YOU ARE OWED", 9, .semibold, .secondaryLabel)
        let leftAmt   = label(CurrencyFormatter.inr(owedToYou), 22, .bold, owedToYou > 0 ? AppTheme.successColor : .label)
        let leftStack = vstack([leftTag, leftAmt], spacing: 3)

        // Divider
        let divider = UIView()
        divider.backgroundColor = AppTheme.primary.withAlphaComponent(0.2)
        divider.translatesAutoresizingMaskIntoConstraints = false

        // Right: you owe
        let rightTag   = label("YOU OWE", 9, .semibold, .secondaryLabel)
        let rightAmt   = label(CurrencyFormatter.inr(youOwe), 22, .bold, youOwe > 0 ? AppTheme.warningColor : .label)
        let rightStack = vstack([rightTag, rightAmt], spacing: 3)

        card.addSubview(leftStack)
        card.addSubview(divider)
        card.addSubview(rightStack)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),

            leftStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            leftStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            divider.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            divider.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalToConstant: 40),

            rightStack.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 20),
            rightStack.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
    }

    // MARK: - Balance Row
    private func buildBalanceRow(_ summary: BalanceSummary, in container: UIView) {
        let card = UIView()
        card.backgroundColor = AppTheme.cardBackground
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 6
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(card)

        let avatarColor = UIColor(hex: summary.person.avatarColor) ?? AppTheme.primary
        let avatar = makeAvatar(name: summary.person.name, color: avatarColor, size: 38)

        let nameLabel = label(summary.person.name, 14, .semibold, .label)
        let isOwed = summary.netAmount > 0
        let subText = isOwed ? "owes you" : "you owe"
        let subLabel = label(subText, 11, .medium, .secondaryLabel)

        let amtLabel = label(CurrencyFormatter.inr(abs(summary.netAmount)), 15, .bold, isOwed ? AppTheme.successColor : AppTheme.warningColor)
        amtLabel.textAlignment = .right
        amtLabel.setContentHuggingPriority(.required, for: .horizontal)

        let settleBtn = UIButton(type: .system)
        settleBtn.setTitle("Settle", for: .normal)
        settleBtn.titleLabel?.font = .systemFont(ofSize: 11, weight: .semibold)
        settleBtn.backgroundColor = AppTheme.primary.withAlphaComponent(0.12)
        settleBtn.setTitleColor(AppTheme.primary, for: .normal)
        settleBtn.layer.cornerRadius = 10
        settleBtn.translatesAutoresizingMaskIntoConstraints = false

        let personId = summary.person.id
        settleBtn.addAction(UIAction { [weak self] _ in
            self?.settleAll(for: personId)
        }, for: .touchUpInside)

        card.addSubview(avatar)
        card.addSubview(nameLabel)
        card.addSubview(subLabel)
        card.addSubview(amtLabel)
        card.addSubview(settleBtn)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),

            avatar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            avatar.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),

            subLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            subLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),

            settleBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            settleBtn.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            settleBtn.widthAnchor.constraint(equalToConstant: 56),
            settleBtn.heightAnchor.constraint(equalToConstant: 28),

            amtLabel.trailingAnchor.constraint(equalTo: settleBtn.leadingAnchor, constant: -10),
            amtLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
    }

    // MARK: - Expense Row
    private func buildExpenseRow(_ expense: SplitExpense, in container: UIView) {
        let card = UIView()
        card.backgroundColor = AppTheme.cardBackground
        card.layer.cornerRadius = 18
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
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
        bar.backgroundColor = expense.category.color
        bar.translatesAutoresizingMaskIntoConstraints = false
        innerClip.addSubview(bar)

        // Icon circle
        let circle = UIView()
        circle.backgroundColor = expense.category.color.withAlphaComponent(0.12)
        circle.layer.cornerRadius = 20
        circle.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(circle)

        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let iconView = UIImageView(image: UIImage(systemName: expense.category.sfSymbol, withConfiguration: cfg))
        iconView.tintColor = expense.category.color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(iconView)

        let titleLabel = label(expense.note.isEmpty ? expense.category.title : expense.note, 14, .semibold, .label)
        titleLabel.numberOfLines = 1

        // Payer info
        let payerName = viewModel.person(for: expense.payerId)?.name ?? "Unknown"
        let payerLabel = label("Paid by \(payerName)", 11, .medium, .secondaryLabel)

        let amtLabel = label(CurrencyFormatter.inr(expense.totalAmount), 15, .bold, .label)
        amtLabel.textAlignment = .right
        amtLabel.setContentHuggingPriority(.required, for: .horizontal)

        let df = DateFormatter()
        df.dateFormat = "d MMM"
        let dateLabel = label(df.string(from: expense.date), 10, .medium, .tertiaryLabel)
        dateLabel.textAlignment = .right

        card.addSubview(titleLabel)
        card.addSubview(payerLabel)
        card.addSubview(amtLabel)
        card.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: container.topAnchor, constant: 5),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -5),

            innerClip.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            innerClip.topAnchor.constraint(equalTo: card.topAnchor),
            innerClip.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            innerClip.widthAnchor.constraint(equalToConstant: 5),

            bar.leadingAnchor.constraint(equalTo: innerClip.leadingAnchor),
            bar.topAnchor.constraint(equalTo: innerClip.topAnchor),
            bar.bottomAnchor.constraint(equalTo: innerClip.bottomAnchor),
            bar.trailingAnchor.constraint(equalTo: innerClip.trailingAnchor),

            circle.leadingAnchor.constraint(equalTo: innerClip.trailingAnchor, constant: 12),
            circle.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            circle.widthAnchor.constraint(equalToConstant: 40),
            circle.heightAnchor.constraint(equalToConstant: 40),

            iconView.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.leadingAnchor.constraint(equalTo: circle.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: amtLabel.leadingAnchor, constant: -8),

            payerLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            payerLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),

            amtLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            amtLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),

            dateLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            dateLabel.topAnchor.constraint(equalTo: amtLabel.bottomAnchor, constant: 4)
        ])
    }

    // MARK: - Empty State
    private func buildEmptyState(in container: UIView) {
        let cfg = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        let icon = UIImageView(image: UIImage(systemName: "person.2.fill", withConfiguration: cfg))
        icon.tintColor = AppTheme.primary.withAlphaComponent(0.3)
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = label("No split expenses yet", 17, .semibold, .label)
        titleLabel.textAlignment = .center

        let subLabel = label("Tap + to add an expense\nand split it with friends", 14, .regular, .secondaryLabel)
        subLabel.textAlignment = .center
        subLabel.numberOfLines = 2

        let stack = UIStackView(arrangedSubviews: [icon, titleLabel, subLabel])
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 60),
            icon.heightAnchor.constraint(equalToConstant: 60),
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }

    // MARK: - Section Header
    private func makeSectionHeader(_ title: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let l = label(title.uppercased(), 11, .semibold, .secondaryLabel)
        l.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(l)
        NSLayoutConstraint.activate([
            l.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            l.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }

    // MARK: - Settle
    private func settleAll(for personId: UUID) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        for expense in viewModel.expenses {
            viewModel.settleShare(expenseId: expense.id, personId: personId)
        }
        viewModel.reload()
        tableView.reloadData()
    }

    // MARK: - Detail
    private func showExpenseDetail(_ expense: SplitExpense) {
        let vc = SplitExpenseDetailViewController(expense: expense, viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Add
    @objc private func addTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let addVC = AddSplitExpenseViewController(viewModel: viewModel)
        addVC.onSave = { [weak self] in
            self?.viewModel.reload()
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(addVC, animated: true)
    }

    // MARK: - Helpers
    private func makeAvatar(name: String, color: UIColor, size: CGFloat) -> UIView {
        let v = UIView()
        v.backgroundColor = color.withAlphaComponent(0.18)
        v.layer.cornerRadius = size / 2
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: size).isActive = true
        v.heightAnchor.constraint(equalToConstant: size).isActive = true

        let l = UILabel()
        l.text = String(name.prefix(1)).uppercased()
        l.font = .systemFont(ofSize: size * 0.4, weight: .bold)
        l.textColor = color
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(l)
        NSLayoutConstraint.activate([
            l.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            l.centerYAnchor.constraint(equalTo: v.centerYAnchor)
        ])
        return v
    }

    private func label(_ text: String, _ size: CGFloat, _ weight: UIFont.Weight, _ color: UIColor) -> UILabel {
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
