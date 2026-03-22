//
//  SplitExpenseDetailViewController.swift
//  MyBudget Pro
//

import UIKit

final class SplitExpenseDetailViewController: UIViewController {

    private var expense: SplitExpense
    private let viewModel: SplitViewModel

    init(expense: SplitExpense, viewModel: SplitViewModel) {
        self.expense = expense
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Split Detail"
        view.backgroundColor = AppTheme.background
        setupScrollView()
        buildContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyAppGradient()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    private func buildContent() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Header card
        let headerCard = UIView()
        headerCard.backgroundColor = AppTheme.primary.withAlphaComponent(0.12)
        headerCard.layer.cornerRadius = 20
        headerCard.layer.borderWidth = 1
        headerCard.layer.borderColor = AppTheme.primary.withAlphaComponent(0.25).cgColor
        headerCard.translatesAutoresizingMaskIntoConstraints = false

        let cfg = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let iconView = UIImageView(image: UIImage(systemName: expense.category.sfSymbol, withConfiguration: cfg))
        iconView.tintColor = expense.category.color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let circle = UIView()
        circle.backgroundColor = expense.category.color.withAlphaComponent(0.15)
        circle.layer.cornerRadius = 28
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(iconView)

        let amtLabel = label(CurrencyFormatter.inr(expense.totalAmount), 32, .bold, .label)
        let noteLabel = label(expense.note.isEmpty ? expense.category.title : expense.note, 15, .medium, .secondaryLabel)
        noteLabel.numberOfLines = 2

        let df = DateFormatter()
        df.dateStyle = .medium
        let dateLabel = label(df.string(from: expense.date), 12, .regular, .tertiaryLabel)

        let payerName = viewModel.person(for: expense.payerId)?.name ?? "Unknown"
        let payerLabel = label("Paid by \(payerName)", 13, .semibold, AppTheme.primary)

        let textStack = UIStackView(arrangedSubviews: [amtLabel, noteLabel, dateLabel, payerLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        headerCard.addSubview(circle)
        headerCard.addSubview(textStack)

        NSLayoutConstraint.activate([
            headerCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 110),
            circle.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 18),
            circle.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),
            circle.widthAnchor.constraint(equalToConstant: 56),
            circle.heightAnchor.constraint(equalToConstant: 56),
            iconView.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            textStack.leadingAnchor.constraint(equalTo: circle.trailingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),
            textStack.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 18),
            textStack.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -18)
        ])
        contentStack.addArrangedSubview(headerCard)

        // Shares section
        let sharesCard = UIView()
        sharesCard.backgroundColor = AppTheme.cardBackground
        sharesCard.layer.cornerRadius = 18
        sharesCard.layer.shadowColor = UIColor.black.cgColor
        sharesCard.layer.shadowOpacity = 0.06
        sharesCard.layer.shadowRadius = 8
        sharesCard.layer.shadowOffset = CGSize(width: 0, height: 3)

        let sharesStack = UIStackView()
        sharesStack.axis = .vertical
        sharesStack.spacing = 0
        sharesStack.translatesAutoresizingMaskIntoConstraints = false
        sharesCard.addSubview(sharesStack)

        NSLayoutConstraint.activate([
            sharesStack.topAnchor.constraint(equalTo: sharesCard.topAnchor, constant: 8),
            sharesStack.leadingAnchor.constraint(equalTo: sharesCard.leadingAnchor),
            sharesStack.trailingAnchor.constraint(equalTo: sharesCard.trailingAnchor),
            sharesStack.bottomAnchor.constraint(equalTo: sharesCard.bottomAnchor, constant: -8)
        ])

        for share in expense.shares {
            guard let person = viewModel.person(for: share.personId) else { continue }
            let row = buildShareRow(person: person, share: share)
            sharesStack.addArrangedSubview(row)
        }

        contentStack.addArrangedSubview(sharesCard)
    }

    private func buildShareRow(person: Person, share: SplitShare) -> UIView {
        let row = UIView()
        row.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let avatarColor = UIColor(hex: person.avatarColor) ?? AppTheme.primary
        let avatar = makeAvatar(name: person.name, color: avatarColor, size: 36)

        let nameLabel = label(person.name, 14, .semibold, .label)
        let amtLabel  = label(CurrencyFormatter.inr(share.amount), 14, .bold, .label)
        amtLabel.textAlignment = .right
        amtLabel.setContentHuggingPriority(.required, for: .horizontal)

        let statusView = UIView()
        statusView.backgroundColor = share.isSettled
            ? AppTheme.successColor.withAlphaComponent(0.12)
            : AppTheme.warningColor.withAlphaComponent(0.12)
        statusView.layer.cornerRadius = 10
        statusView.translatesAutoresizingMaskIntoConstraints = false

        let statusLabel = label(share.isSettled ? "Settled" : "Pending", 11, .semibold,
                                share.isSettled ? AppTheme.successColor : AppTheme.warningColor)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusView.addSubview(statusLabel)

        row.addSubview(avatar)
        row.addSubview(nameLabel)
        row.addSubview(amtLabel)
        row.addSubview(statusView)

        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            avatar.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            statusView.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            statusView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            statusLabel.topAnchor.constraint(equalTo: statusView.topAnchor, constant: 4),
            statusLabel.bottomAnchor.constraint(equalTo: statusView.bottomAnchor, constant: -4),
            statusLabel.leadingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: -8),

            amtLabel.trailingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: -10),
            amtLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])

        return row
    }

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
}
