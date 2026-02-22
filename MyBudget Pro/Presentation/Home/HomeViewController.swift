
//
//  HomeViewController.swift
//  MyBudget Pro
//

import UIKit
import Lottie

final class HomeViewController: UIViewController,
                                UITableViewDataSource,
                                UITableViewDelegate {

    // MARK: - Dependencies
    private let viewModel: HomeViewModel

    // MARK: - State
    private var viewState: HomeViewState?

    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let addButton = UIButton(type: .system)
    private var hasShownWelcome = false

    // Empty state
    private let emptyAnimation = LottieAnimationView(
        animation: LottieAnimation.named("wallet")
    )

    // ✅ NEW: Empty guidance
    private let emptyHintLabel = UILabel()
    private let emptyArrow = UIImageView()

    // Welcome popup
    private let welcomeOverlay = UIView()
    private let welcomeCard = UIView()

    // MARK: - Init
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recent"

        view.backgroundColor = AppTheme.background
        view.addBackgroundLottie(named: "background_motion")

        setupTable()
        setupFloatingButton()
        setupEmptyState()
        setupEmptyHint()              // ✅ NEW
        setupThemeToggleButton()
        syncThemeButtonWithSystem()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
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

    // MARK: - Reload
    private func reload() {
        let state = viewModel.makeViewState()
        self.viewState = state

        tableView.reloadData()
        updateEmptyState(isEmpty: state.isEmpty)
    }

    // MARK: - Theme (UNCHANGED)
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        syncThemeButtonWithSystem()
    }

    private func setupThemeToggleButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "moon.fill"),
            style: .plain,
            target: self,
            action: #selector(themeToggleTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .label
    }

    private func syncThemeButtonWithSystem() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        navigationItem.rightBarButtonItem?.image =
            UIImage(systemName: isDark ? "sun.max.fill" : "moon.fill")
    }

    @objc private func themeToggleTapped() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        view.window?.overrideUserInterfaceStyle = isDark ? .light : .dark
        (tabBarController as? MainTabBarController)?.applyTabBarTheme()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
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

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Empty State
    private func setupEmptyState() {
        emptyAnimation.loopMode = .loop
        emptyAnimation.translatesAutoresizingMaskIntoConstraints = false
        emptyAnimation.isHidden = true

        view.addSubview(emptyAnimation)

        NSLayoutConstraint.activate([
            emptyAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyAnimation.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
            emptyAnimation.widthAnchor.constraint(equalToConstant: 220),
            emptyAnimation.heightAnchor.constraint(equalToConstant: 220)
        ])
    }

    // MARK: - Empty Hint (NEW)
    private func setupEmptyHint() {
        emptyHintLabel.text = "Start by adding your first expense"
        emptyHintLabel.font = .systemFont(ofSize: 15, weight: .medium)
        emptyHintLabel.textColor = .secondaryLabel
        emptyHintLabel.textAlignment = .center
        emptyHintLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyHintLabel.isHidden = true

        emptyArrow.image = UIImage(systemName: "arrow.down")
        emptyArrow.tintColor = .secondaryLabel
        emptyArrow.translatesAutoresizingMaskIntoConstraints = false
        emptyArrow.isHidden = true

        view.addSubview(emptyHintLabel)
        view.addSubview(emptyArrow)

        NSLayoutConstraint.activate([
            emptyHintLabel.topAnchor.constraint(equalTo: emptyAnimation.bottomAnchor, constant: 12),
            emptyHintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            emptyArrow.topAnchor.constraint(equalTo: emptyHintLabel.bottomAnchor, constant: 8),
            emptyArrow.centerXAnchor.constraint(equalTo: addButton.centerXAnchor)
        ])
    }

    private func updateEmptyState(isEmpty: Bool) {
        emptyAnimation.isHidden = !isEmpty
        emptyHintLabel.isHidden = !isEmpty
        emptyArrow.isHidden = !isEmpty
        tableView.isHidden = isEmpty

        if isEmpty {
            emptyAnimation.play()
            animateArrow()
        } else {
            emptyAnimation.stop()
            emptyArrow.layer.removeAllAnimations()
        }
    }

    private func animateArrow() {
        emptyArrow.transform = .identity
        UIView.animate(
            withDuration: 0.8,
            delay: 0,
            options: [.autoreverse, .repeat, .curveEaseInOut]
        ) {
            self.emptyArrow.transform = CGAffineTransform(translationX: 0, y: 8)
        }
    }

    // MARK: - Floating Button
    private func setupFloatingButton() {
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .white
        addButton.backgroundColor = AppTheme.primary
        addButton.layer.cornerRadius = 28
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
        navigationController?.pushViewController(AddExpenseViewController(), animated: true)
    }

    // MARK: - Table DataSource (UNCHANGED)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewState?.expenses.count ?? 0
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        guard let expense = viewState?.expenses[indexPath.row] else {
            return cell
        }

        let cardHeight: CGFloat = 72

        let card = UIView(frame: CGRect(
            x: 20,
            y: 6,
            width: tableView.bounds.width - 40,
            height: cardHeight
        ))
        card.applyCardStyle()

        let iconSize = cardHeight * 0.65
        let lottieView = LottieAnimationView(
            animation: LottieAnimation.named(expense.category.lottieName)
        )
        lottieView.frame = CGRect(
            x: 14,
            y: (cardHeight - iconSize) / 2,
            width: iconSize,
            height: iconSize
        )
        lottieView.loopMode = .loop
        lottieView.play()

        let titleLabel = UILabel(frame: CGRect(
            x: 14 + iconSize + 10,
            y: 12,
            width: card.bounds.width - 200,
            height: 20
        ))
        titleLabel.text = expense.category.title
        titleLabel.font = .boldSystemFont(ofSize: 15)

        let noteLabel = UILabel(frame: CGRect(
            x: 14 + iconSize + 10,
            y: 34,
            width: card.bounds.width - 200,
            height: 16
        ))
        noteLabel.text = expense.note.isEmpty ? "—" : expense.note
        noteLabel.font = .systemFont(ofSize: 12)
        noteLabel.textColor = .secondaryLabel

        let amountLabel = UILabel()
        amountLabel.text = CurrencyFormatter.inr(expense.amount)
        amountLabel.font = .boldSystemFont(ofSize: 15)
        amountLabel.textAlignment = .right
        amountLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(lottieView)
        card.addSubview(titleLabel)
        card.addSubview(noteLabel)
        card.addSubview(amountLabel)

        NSLayoutConstraint.activate([
            amountLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            amountLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            amountLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: titleLabel.trailingAnchor,
                constant: 8
            )
        ])

        cell.contentView.addSubview(card)
        return cell
    }

    // MARK: - Delete (UNCHANGED)
    func tableView(_ tableView: UITableView,
                   canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        guard editingStyle == .delete,
              let expense = viewState?.expenses[indexPath.row]
        else { return }

        viewModel.deleteExpense(id: expense.id)
        reload()
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        88
    }

    // MARK: - Welcome Popup (UNCHANGED)
    private func showWelcomePopupIfNeeded() {
        guard let name = UserSession.userName,
              welcomeOverlay.superview == nil else { return }

        welcomeOverlay.frame = view.bounds
        welcomeOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        welcomeOverlay.alpha = 0
        view.addSubview(welcomeOverlay)

        welcomeCard.backgroundColor = .systemBackground
        welcomeCard.layer.cornerRadius = 16
        welcomeCard.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Welcome,\n\(name) 👋"
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = 2

        let button = UIButton(type: .system)
        button.setTitle("Thanks", for: .normal)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(dismissWelcomePopup), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [label, button])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        welcomeCard.addSubview(stack)
        welcomeOverlay.addSubview(welcomeCard)

        NSLayoutConstraint.activate([
            welcomeCard.centerXAnchor.constraint(equalTo: welcomeOverlay.centerXAnchor),
            welcomeCard.centerYAnchor.constraint(equalTo: welcomeOverlay.centerYAnchor),
            welcomeCard.widthAnchor.constraint(equalToConstant: 260),

            stack.topAnchor.constraint(equalTo: welcomeCard.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: welcomeCard.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: welcomeCard.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: welcomeCard.trailingAnchor, constant: -20)
        ])

        UIView.animate(withDuration: 0.25) {
            self.welcomeOverlay.alpha = 1
        }
    }

    @objc private func dismissWelcomePopup() {
        UIView.animate(withDuration: 0.25, animations: {
            self.welcomeOverlay.alpha = 0
        }) { _ in
            self.welcomeOverlay.removeFromSuperview()
        }
    }
}
