//
//  HomeViewController.swift
//  MyBudget Pro
//

import UIKit
import Lottie

final class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Dependencies
    private let viewModel: HomeViewModel

    // MARK: - State
    private var viewState: HomeViewState?
    private var dailyQuote: DailyQuote?
    private var hasShownWelcome = false

    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let addButton = UIButton(type: .system)
    private let emptyAnimation = LottieAnimationView(animation: LottieAnimation.named("wallet"))
    private let emptyHintLabel = UILabel()
    private let welcomeOverlay = UIView()
    private let welcomeCard = UIView()

    // MARK: - Init
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recent"
        view.backgroundColor = AppTheme.background
        view.addBackgroundLottie(named: "background_motion")
        setupTable()
        setupFloatingButton()
        setupEmptyState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
        fetchQuoteIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasShownWelcome else { return }
        hasShownWelcome = true
        showWelcomePopupIfNeeded()
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

    // MARK: - Data
    private func reload() {
        viewState = viewModel.makeViewState()
        tableView.reloadData()
        updateEmptyState(isEmpty: viewState?.isEmpty ?? true)
    }

    private func fetchQuoteIfNeeded() {
        guard dailyQuote == nil else { return }
        Task { [weak self] in
            let quote = await QuoteService.shared.fetchTodayQuote()
            await MainActor.run {
                self?.dailyQuote = quote
                self?.tableView.reloadData()
            }
        }
    }

    // MARK: - Table Setup
    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 100, right: 0)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Empty State
    private func setupEmptyState() {
        emptyAnimation.loopMode = .loop
        emptyAnimation.translatesAutoresizingMaskIntoConstraints = false
        emptyAnimation.isHidden = true

        emptyHintLabel.text = "Add your first expense"
        emptyHintLabel.font = .systemFont(ofSize: 15, weight: .medium)
        emptyHintLabel.textColor = .secondaryLabel
        emptyHintLabel.textAlignment = .center
        emptyHintLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyHintLabel.isHidden = true

        view.addSubview(emptyAnimation)
        view.addSubview(emptyHintLabel)

        NSLayoutConstraint.activate([
            emptyAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyAnimation.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            emptyAnimation.widthAnchor.constraint(equalToConstant: 200),
            emptyAnimation.heightAnchor.constraint(equalToConstant: 200),
            emptyHintLabel.topAnchor.constraint(equalTo: emptyAnimation.bottomAnchor, constant: 8),
            emptyHintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func updateEmptyState(isEmpty: Bool) {
        emptyAnimation.isHidden = !isEmpty
        emptyHintLabel.isHidden = !isEmpty
        isEmpty ? emptyAnimation.play() : emptyAnimation.stop()
    }

    // MARK: - Floating Button
    private func setupFloatingButton() {
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

    @objc private func addTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        navigationController?.pushViewController(AddExpenseViewController(), animated: true)
    }

    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int { 3 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return dailyQuote != nil ? 1 : 0
        case 2: return viewState?.expenses.count ?? 0
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        switch indexPath.section {
        case 0:
            if let state = viewState { buildSummaryCard(in: cell.contentView, state: state) }
        case 1:
            if let quote = dailyQuote { buildQuoteCard(in: cell.contentView, quote: quote) }
        default:
            if let expense = viewState?.expenses[indexPath.row] {
                buildExpenseCard(in: cell.contentView, expense: expense)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 130
        case 1: return UITableView.automaticDimension
        default: return 84
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 1 ? 130 : 84
    }

    // MARK: - Summary Card
    private func buildSummaryCard(in container: UIView, state: HomeViewState) {
        let card = UIView()
        card.backgroundColor = AppTheme.primary.withAlphaComponent(0.12)
        card.layer.cornerRadius = 22
        card.layer.borderWidth = 1
        card.layer.borderColor = AppTheme.primary.withAlphaComponent(0.25).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(card)

        let total = state.expenses.reduce(0) { $0 + $1.amount }

        // Left: amount stack
        let tagLabel = makeLabel("TOTAL SPENT", 10, .semibold, .secondaryLabel)
        tagLabel.letterSpacing(1.0)
        let totalLabel = makeLabel(CurrencyFormatter.inr(total), 30, .bold, .label)
        totalLabel.adjustsFontSizeToFitWidth = true
        totalLabel.minimumScaleFactor = 0.7
        let compLabel = makeLabel(state.monthComparisonText, 12, .medium, .secondaryLabel)
        compLabel.numberOfLines = 1
        compLabel.adjustsFontSizeToFitWidth = true
        compLabel.minimumScaleFactor = 0.8
        let leftStack = vstack([tagLabel, totalLabel, compLabel], spacing: 3)

        // Right: count badge
        let countBadge = UIView()
        countBadge.backgroundColor = AppTheme.primary.withAlphaComponent(0.15)
        countBadge.layer.cornerRadius = 12
        countBadge.translatesAutoresizingMaskIntoConstraints = false

        let countLabel = makeLabel("\(state.expenses.count)", 18, .bold, AppTheme.primary)
        countLabel.textAlignment = .center
        let txLabel = makeLabel("txns", 10, .semibold, AppTheme.primary.withAlphaComponent(0.7))
        txLabel.textAlignment = .center
        let badgeStack = vstack([countLabel, txLabel], spacing: 0)
        badgeStack.alignment = .center
        countBadge.addSubview(badgeStack)

        card.addSubview(leftStack)
        card.addSubview(countBadge)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),

            leftStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            leftStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            leftStack.trailingAnchor.constraint(lessThanOrEqualTo: countBadge.leadingAnchor, constant: -12),

            countBadge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            countBadge.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            countBadge.widthAnchor.constraint(equalToConstant: 56),
            countBadge.heightAnchor.constraint(equalToConstant: 56),

            badgeStack.centerXAnchor.constraint(equalTo: countBadge.centerXAnchor),
            badgeStack.centerYAnchor.constraint(equalTo: countBadge.centerYAnchor)
        ])
    }

    // MARK: - Quote Card (Daily Insight)
    private func buildQuoteCard(in container: UIView, quote: DailyQuote) {
        let card = UIView()
        card.backgroundColor = AppTheme.cardBackground
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.07
        card.layer.shadowRadius = 10
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(card)

        // Left accent bar
        let innerClip = UIView()
        innerClip.layer.cornerRadius = 20
        innerClip.clipsToBounds = true
        innerClip.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(innerClip)

        let accentBar = UIView()
        accentBar.backgroundColor = AppTheme.primary
        accentBar.translatesAutoresizingMaskIntoConstraints = false
        innerClip.addSubview(accentBar)

        // Top row: pill badge
        let pill = UIView()
        pill.backgroundColor = AppTheme.primary.withAlphaComponent(0.12)
        pill.layer.cornerRadius = 9
        pill.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(pill)

        let pillLabel = makeLabel("✦  Daily Insight", 10, .semibold, AppTheme.primary)
        pillLabel.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(pillLabel)

        // Quote icon
        let iconCfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        let icon = UIImageView(image: UIImage(systemName: "quote.opening", withConfiguration: iconCfg))
        icon.tintColor = AppTheme.primary.withAlphaComponent(0.6)
        icon.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(icon)

        // Quote text — full width, multi-line, no truncation
        let quoteLabel = makeLabel(quote.text, 13, .medium, .label)
        quoteLabel.numberOfLines = 0
        quoteLabel.lineBreakMode = .byWordWrapping
        card.addSubview(quoteLabel)

        // Author
        let authorLabel = makeLabel("— \(quote.author)", 11, .semibold, AppTheme.primary)
        card.addSubview(authorLabel)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),

            innerClip.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            innerClip.topAnchor.constraint(equalTo: card.topAnchor),
            innerClip.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            innerClip.widthAnchor.constraint(equalToConstant: 4),

            // Pill top-right
            pill.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            pill.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            pillLabel.topAnchor.constraint(equalTo: pill.topAnchor, constant: 4),
            pillLabel.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -4),
            pillLabel.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 8),
            pillLabel.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -8),

            // Icon below pill, left side
            icon.leadingAnchor.constraint(equalTo: innerClip.trailingAnchor, constant: 14),
            icon.topAnchor.constraint(equalTo: pill.bottomAnchor, constant: 10),

            // Quote text: full width below pill, beside icon
            quoteLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 6),
            quoteLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            quoteLabel.topAnchor.constraint(equalTo: pill.bottomAnchor, constant: 10),

            // Author below quote
            authorLabel.leadingAnchor.constraint(equalTo: quoteLabel.leadingAnchor),
            authorLabel.topAnchor.constraint(equalTo: quoteLabel.bottomAnchor, constant: 8),
            authorLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            authorLabel.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Expense Card
    private func buildExpenseCard(in container: UIView, expense: Expense) {
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

        // Accent bar (clipped separately)
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

        let emojiLabel = makeLabel(expense.category.emoji, 20, .regular, .label)
        emojiLabel.textAlignment = .center
        card.addSubview(emojiLabel)

        let titleLabel = makeLabel(expense.category.title, 14, .semibold, .label)
        titleLabel.numberOfLines = 1
        card.addSubview(titleLabel)

        let noteLabel = makeLabel(expense.note.isEmpty ? "No note" : expense.note, 12, .regular, .secondaryLabel)
        noteLabel.numberOfLines = 1
        card.addSubview(noteLabel)

        let amountLabel = makeLabel(CurrencyFormatter.inr(expense.amount), 15, .bold, .label)
        amountLabel.textAlignment = .right
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        card.addSubview(amountLabel)

        // Date label
        let df = DateFormatter()
        df.dateFormat = "d MMM"
        let dateLabel = makeLabel(df.string(from: expense.date), 10, .medium, .tertiaryLabel)
        dateLabel.textAlignment = .right
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

            emojiLabel.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: circle.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: circle.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),

            noteLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            noteLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            noteLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),

            amountLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            amountLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),

            dateLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            dateLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 4)
        ])
    }

    // MARK: - Delete
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        indexPath.section == 2
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete, indexPath.section == 2,
              let expense = viewState?.expenses[indexPath.row] else { return }
        viewModel.deleteExpense(id: expense.id)
        reload()
    }

    // MARK: - Welcome Popup
    private func showWelcomePopupIfNeeded() {
        guard let name = UserSession.userName, welcomeOverlay.superview == nil else { return }

        welcomeOverlay.translatesAutoresizingMaskIntoConstraints = false
        welcomeOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        welcomeOverlay.alpha = 0
        view.addSubview(welcomeOverlay)
        NSLayoutConstraint.activate([
            welcomeOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            welcomeOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            welcomeOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            welcomeOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        welcomeCard.backgroundColor = AppTheme.cardBackground
        welcomeCard.layer.cornerRadius = 28
        welcomeCard.layer.shadowColor = UIColor.black.cgColor
        welcomeCard.layer.shadowOpacity = 0.25
        welcomeCard.layer.shadowRadius = 30
        welcomeCard.layer.shadowOffset = CGSize(width: 0, height: 12)
        welcomeCard.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        welcomeCard.translatesAutoresizingMaskIntoConstraints = false

        let accentBar = UIView()
        accentBar.backgroundColor = AppTheme.primary
        accentBar.layer.cornerRadius = 3
        accentBar.translatesAutoresizingMaskIntoConstraints = false

        let emojiLabel = makeLabel("👋", 44, .regular, .label)
        emojiLabel.textAlignment = .center
        let greetLabel = makeLabel("Welcome back,", 14, .medium, .secondaryLabel)
        greetLabel.textAlignment = .center
        let nameLabel = makeLabel(name, 26, .bold, .label)
        nameLabel.textAlignment = .center
        let subLabel = makeLabel("Ready to track your expenses?", 13, .regular, .tertiaryLabel)
        subLabel.textAlignment = .center

        let button = UIButton(type: .system)
        button.setTitle("Let's go  →", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = AppTheme.primary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dismissWelcomePopup), for: .touchUpInside)

        welcomeCard.addSubview(accentBar)
        welcomeCard.addSubview(emojiLabel)
        welcomeCard.addSubview(greetLabel)
        welcomeCard.addSubview(nameLabel)
        welcomeCard.addSubview(subLabel)
        welcomeCard.addSubview(button)
        welcomeOverlay.addSubview(welcomeCard)

        NSLayoutConstraint.activate([
            welcomeCard.centerXAnchor.constraint(equalTo: welcomeOverlay.centerXAnchor),
            welcomeCard.centerYAnchor.constraint(equalTo: welcomeOverlay.centerYAnchor),
            welcomeCard.widthAnchor.constraint(equalToConstant: 300),

            accentBar.topAnchor.constraint(equalTo: welcomeCard.topAnchor, constant: 20),
            accentBar.centerXAnchor.constraint(equalTo: welcomeCard.centerXAnchor),
            accentBar.widthAnchor.constraint(equalToConstant: 40),
            accentBar.heightAnchor.constraint(equalToConstant: 4),

            emojiLabel.topAnchor.constraint(equalTo: accentBar.bottomAnchor, constant: 20),
            emojiLabel.centerXAnchor.constraint(equalTo: welcomeCard.centerXAnchor),
            greetLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 16),
            greetLabel.centerXAnchor.constraint(equalTo: welcomeCard.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: greetLabel.bottomAnchor, constant: 4),
            nameLabel.centerXAnchor.constraint(equalTo: welcomeCard.centerXAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: welcomeCard.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: welcomeCard.trailingAnchor, constant: -20),
            subLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            subLabel.centerXAnchor.constraint(equalTo: welcomeCard.centerXAnchor),
            button.topAnchor.constraint(equalTo: subLabel.bottomAnchor, constant: 24),
            button.leadingAnchor.constraint(equalTo: welcomeCard.leadingAnchor, constant: 24),
            button.trailingAnchor.constraint(equalTo: welcomeCard.trailingAnchor, constant: -24),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.bottomAnchor.constraint(equalTo: welcomeCard.bottomAnchor, constant: -24)
        ])

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 0.5) {
            self.welcomeOverlay.alpha = 1
            self.welcomeCard.transform = .identity
        }
    }

    @objc private func dismissWelcomePopup() {
        UIView.animate(withDuration: 0.2, animations: {
            self.welcomeOverlay.alpha = 0
            self.welcomeCard.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in self.welcomeOverlay.removeFromSuperview() }
    }

    // MARK: - Helpers
    private func makeLabel(_ text: String, _ size: CGFloat, _ weight: UIFont.Weight, _ color: UIColor) -> UILabel {
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

private extension UILabel {
    func letterSpacing(_ spacing: CGFloat) {
        guard let text = text else { return }
        attributedText = NSAttributedString(string: text, attributes: [.kern: spacing])
    }
}
